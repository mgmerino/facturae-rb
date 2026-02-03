# Medium Priority Roadmap Plan

Scope: items listed under "Medium Priority" in `README.md`.

## 1) Upgrade to SHA256 for signing

### Goal

Replace RSA-SHA1 with RSA-SHA256 while preserving interoperability.

### Design Notes

- Update algorithm URIs in XAdES elements.
- Update OpenSSL digest usage to SHA256.
- Consider a configuration flag for legacy SHA1 support.

### Implementation Steps

- Update signing digest in `lib/facturae/xades/signer.rb`.
- Update any algorithm URIs in `signed_info.rb` and related builders.
- Add configuration option for algorithm selection (default SHA256).
- Update test fixtures and expected signature values.

### Tests

- Unit specs verifying algorithm URIs in generated XML.
- Integration spec with SHA256 signature verification.

### Acceptance Criteria

- Default signing uses SHA256.
- Optional SHA1 support is documented (if kept).

## 2) Make signer role configurable

### Goal

Allow roles beyond "supplier" in `QualifyingProperties`.

### Design Notes

- Add a signer role option to `Signer` or `ObjectInfo`.
- Validate that role values are from a known set.

### Implementation Steps

- Add a new option in `lib/facturae/xades/object_info.rb`.
- Wire option through `Signer` and builders.
- Update tests to cover custom roles.

### Tests

- Unit spec for role value insertion in XML.

### Acceptance Criteria

- Role is configurable and defaults to current behavior.

## 3) Add certificate expiration check

### Goal

Prevent signing with expired or not-yet-valid certificates.

### Design Notes

- Check `not_before` and `not_after` on `OpenSSL::X509::Certificate`.
- Raise a meaningful error when invalid.

### Implementation Steps

- Add validation method in `lib/facturae/xades/signer.rb`.
- Add tests with fixtures for expired and not-yet-valid certs.

### Tests

- Spec coverage for invalid cert errors.

### Acceptance Criteria

- Signing fails fast with clear errors on invalid certs.

## 4) Add XML Schema validation

### Goal

Validate generated XML against the official Facturae 3.2.2 XSD.

### Design Notes

- Store the XSD in `spec/fixtures/` or `lib/` with clear provenance.
- Use `Nokogiri::XML::Schema` for validation.
- Provide a public API method, e.g. `Facturae::FacturaeBuilder#validate`.

### Implementation Steps

- Add a validator class/module under `lib/facturae/`.
- Add schema loading and validation errors as structured output.
- Add tests for invalid and valid documents.

### Tests

- Unit specs for schema validation error collection.
- Integration spec for a known-good invoice fixture.

### Acceptance Criteria

- XML validation errors are predictable and actionable.

## 5) Invoice total auto-calculation from lines

### Goal

Compute totals automatically from line items and taxes.

### Design Notes

- Prefer explicit method to compute totals rather than implicit mutation.
- Preserve existing manual totals for backward compatibility.

### Implementation Steps

- Add a method to `lib/facturae/models/invoice.rb` to compute totals.
- Include discounts and charges in the calculation.
- Update or add tests to confirm totals match expected sums.

### Tests

- Unit tests for line-based totals and tax aggregation.

### Acceptance Criteria

- Computed totals match invoice lines and taxes.
- Manual override remains possible.
