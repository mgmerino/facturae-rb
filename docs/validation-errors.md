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
| **Line** | `item_description must be a String`, `quantity must be a Float`, `unit_price_without_tax must be a Float`, `total_cost must be a Float`, `gross_amount must be a Float`, `article_code must be a String`, `discounts_and_rebates[i].reason must be a String`, `discounts_and_rebates[i].amount must be a Float`, `charges[i].reason must be a String`, `charges[i].amount must be a Float` |
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
