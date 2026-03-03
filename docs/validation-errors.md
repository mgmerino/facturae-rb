# Validation Error Messages

## Overview

All Facturae models now provide human-readable error messages when validation fails. The public API is unchanged — `valid?` still returns `true`/`false` — but you can now inspect `errors` to see *what* failed.

## Usage

```ruby
address = Facturae::Address.new(
  address: nil, post_code: "28002", province: "Madrid", country_code: "USA"
)

address.valid?   # => false
address.errors   # => ["address is required", "country_code is not a valid EU country code"]
```

### Nested dot-path errors

Errors from child objects are automatically prefixed with their path:

```ruby
party = Facturae::Party.new(
  person_type_code: "F",
  residence_type_code: "R",
  tax_id_number: "A12345678"
)
party.subject.type = :unknown
party.valid?   # => false
party.errors   # => ["subject.type must be :individual or :legal"]
```

For collections, errors include the index:

```ruby
invoice = Facturae::Invoice.new
bad_tax = Facturae::Tax.new(tax_type_code: "ZZ", tax_rate: 0.21, tax_amount: 0.21, taxable_base: 1.0)
invoice.add_tax_output(bad_tax)
invoice.valid?   # => false
invoice.errors   # => ["taxes_output[0].tax_type_code is not a valid tax type"]
```

## Architecture

### `Facturae::Validatable` module

Included by all model classes. Provides:

| Method | Visibility | Description |
|--------|-----------|-------------|
| `valid?` | public | Calls `validate`, returns `errors.empty?` |
| `errors` | public | Returns the array of error message strings |
| `validate` | private | Subclasses override this to populate errors (must call `super`) |
| `add_error(msg)` | private | Appends a message to `@errors` |
| `validate_child(name, child)` | private | Validates a single child object, prefixing its errors with `name.` |
| `validate_children(name, children)` | private | Validates a collection, prefixing errors with `name[i].` |

### Model error messages

| Model | Error messages |
|-------|---------------|
| **Address** | `address is required`, `post_code is required`, `province is required`, `country_code is required`, `country_code is not a valid EU country code`, `town is required when country_code is ESP` |
| **Tax** | `tax_type_code is not a valid tax type`, `tax_rate must be a Float`, `tax_amount must be a Float`, `taxable_base must be a Float` |
| **Line** | `item_description must be a String`, `item_description must not be empty`, `quantity must be a Float`, `unit_price_without_tax must be a Float`, `total_cost must be a Float`, `gross_amount must be a Float`, `article_code must be a String`, `discounts_and_rebates[i].reason must be a String`, `discounts_and_rebates[i].amount must be a Float`, `charges[i].reason must be a String`, `charges[i].amount must be a Float`, `total_cost must equal quantity * unit_price_without_tax`, `gross_amount must equal total_cost - discounts + charges` |
| **Subject** | `type must be :individual or :legal`, `name_field1 must be a String`, `name_field2 must be a String` + nested `address_in_spain.*`, `overseas_address.*` |
| **Party** | `person_type_code must be F or J`, `residence_type_code must be R, E, or U`, `tax_id_number must be a String` + nested `subject.*` |
| **Invoice** | `invoice_header contains unknown key: <key>`, `issue_data contains unknown key: <key>`, `totals contains unknown key: <key>` + nested `taxes_output[i].*`, `taxes_withheld[i].*`, `invoice_lines[i].*` |
| **FileHeader** | `modality must be I or L`, `invoice_issuer_type must be EM or RE`, `batch contains unknown key: <key>`, `batch.invoices_count must be an Integer`, `batch.total_invoice_amount must be a Float`, `batch.total_tax_outputs must be a Float`, `batch.total_tax_inputs must be a Float`, `batch.invoice_currency_code must be a String` |
| **FacturaeDocument** | `invoices must not be empty` + nested `invoices[i].*`, `file_header.*`, `seller_party.*`, `buyer_party.*` |

## Files changed

- **Created**: `lib/facturae/validatable.rb` — shared `Validatable` module
- **Modified**: `lib/facturae.rb` — added `require_relative` for the new module
- **Modified**: All 8 model files in `lib/facturae/models/` — included `Validatable`, replaced `valid?` with private `validate`
- **Modified**: All 8 spec files in `spec/lib/facturae/models/` — added `#errors` describe blocks

---

# XAdES Signature Fixes (FACe Validator Compliance)

## Overview

The FACe validator (`se-proveedores-face.redsara.es`) rejected invoices signed by facturae-rb with three signature-related errors. Seven bugs were identified by comparing the output against a canonical valid XML.

## Bugs fixed

### Bug 1 — SHA1 → SHA512 signature algorithm
- `SignatureMethod` and `calculate_signature` now use `rsa-sha512` instead of `rsa-sha1`.

### Bug 2 — Malformed SigPolicyId structure
- `SigPolicyId/Identifier` now contains the policy URL (not the OID).
- `Description` is a sibling of `Identifier` (was incorrectly nested as a child).

### Bug 3 — Spurious SigPolicyQualifiers
- Removed `SigPolicyQualifiers` element entirely (absent in canonical XML).

### Bug 4 — Broken ID wiring between Signer and SignedInfo
- Signer now passes all IDs (`signed_properties_id`, `certificate_id`, `reference_id`) to SignedInfo.
- SignedInfo no longer generates its own random IDs — it uses the ones from Signer.
- URI cross-references use proper `#` prefix (`"#SignedPropertiesID..."`, `"#Certificate..."`).

### Bug 5 — ClaimedRole language
- Changed `ClaimedRole` from `"supplier"` to `"emisor"`.

### Bug 6 — Wrong MIME type
- Changed `MimeType` from `"application/xml"` to `"text/xml"`.

### Bug 7 — Empty signed properties digest
- Reordered `sign` method: KeyInfo and ObjectInfo are now added to the DOM **before** SignedInfo is built, so SignedInfo can find and digest the `SignedProperties` and `KeyInfo` nodes by their `Id` attributes.

## Files changed

| File | Changes |
|------|---------|
| `lib/facturae/xades/signer.rb` | Reorder sign method, pass full IDs to SignedInfo, SHA512 algorithm + digest |
| `lib/facturae/xades/signed_info.rb` | Accept IDs from signer (no random generation), fix URI `#` prefixes, SHA512 algorithm |
| `lib/facturae/xades/object_info.rb` | Fix SigPolicyId structure, remove SigPolicyQualifiers, `"emisor"`, `"text/xml"` |
| `spec/lib/facturae/xades/signer_spec.rb` | Reorder mock tests to match new sign method flow |
| `spec/lib/facturae/xades/signed_info_spec.rb` | Updated constructor to pass all required IDs |

---

# XSD Schema Namespace Compliance

## Overview

The generated XML used a default namespace (`xmlns="..."`) on the root element, which forced Nokogiri to emit `xmlns=""` on every child element group to undeclare it. While technically valid XML, this is unusual and some validators reject it. The canonical Facturae examples use a prefixed namespace on the root instead.

## Issues fixed

### Issue 1 — `xmlns=""` on child elements

**Before:**
```xml
<Facturae xmlns="http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml">
  <FileHeader xmlns="">
```

**After:**
```xml
<fe:Facturae xmlns:fe="http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <FileHeader>
```

The root element now uses the `fe:` prefix. Child elements (`FileHeader`, `Parties`, `Invoices`) are unqualified (no namespace), matching the XSD's default `elementFormDefault="unqualified"`. The `xmlns:ds` declaration is also placed on the root so the `ds:Signature` node inherits it.

### Issue 2 — `<TradeName/>` emitted when nil

**Before:** An empty `<TradeName/>` was always emitted for `LegalEntity`, even when `name_field2` was `nil`.

**After:** `TradeName` is only emitted when `name_field2` is present, matching the schema's `minOccurs="0"`.

### Issue 3 — Redundant `xmlns:ds` on `ds:Signature`

**Before:** `ds:Signature` redeclared `xmlns:ds` even though it was already available from the root.

**After:** Only `xmlns:xades` is declared on the `ds:Signature` node; `xmlns:ds` is inherited from the root.

## Files changed

| File | Changes |
|------|---------|
| `lib/facturae/builders/facturae_builder.rb` | Build XML without namespace, then post-process to add `fe:` prefix and `xmlns:ds` to root |
| `lib/facturae/builders/file_header_builder.rb` | Remove `xmlns: ""` |
| `lib/facturae/builders/parties_builder.rb` | Remove `xmlns: ""`, make `TradeName` conditional |
| `lib/facturae/builders/invoices_builder.rb` | Remove `xmlns: ""` |
| `lib/facturae/xades/signer.rb` | Remove redundant `xmlns:ds` from Signature node |
| `spec/lib/facturae/builders/facturae_builder_spec.rb` | Update expected XML to use `fe:` prefix |
| `spec/lib/facturae/builders/file_header_builder_spec.rb` | Remove `xmlns=""` from expected XML |
| `spec/lib/facturae/builders/parties_builder_spec.rb` | Remove `xmlns=""` from expected XML |
| `spec/lib/facturae/builders/invoices_builder_spec.rb` | Remove `xmlns=""` from expected XML |
