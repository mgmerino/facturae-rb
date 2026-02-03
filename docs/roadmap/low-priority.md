# Low Priority Roadmap Plan

Scope: items listed under "Low Priority" in `README.md`.

## 1) Support XAdES-T (timestamping)

### Goal

Add timestamp tokens to signatures for long-term validation.

### Design Notes

- Requires TSA integration and additional XML nodes.
- May need a pluggable timestamp provider interface.

### Implementation Steps

- Define an interface for timestamp acquisition.
- Add timestamp properties to XAdES XML structure.
- Update signer to include timestamp tokens.
- Add fixtures for timestamp responses.

### Tests

- Unit tests for timestamp XML insertion.
- Integration tests with a mock TSA provider.

### Acceptance Criteria

- Signed XML contains XAdES-T elements with valid timestamp tokens.

## 2) Payment information models

### Goal

Represent payment terms and means in the invoice.

### Design Notes

- Introduce new models under `lib/facturae/models/`.
- Extend builders to include payment sections.

### Implementation Steps

- Add `Payment` and `PaymentMeans` models.
- Update invoice builder to include payment data.
- Add validation rules for payment fields.

### Tests

- Unit tests for payment model validation.
- Builder tests for XML output.

### Acceptance Criteria

- Payment data appears in generated XML and validates against schema.

## 3) Attachment support

### Goal

Attach documents to invoice or signature as supported by Facturae.

### Design Notes

- Attachments may require base64 encoding and metadata.
- Decide whether attachments live in the invoice or signature section.

### Implementation Steps

- Add `Attachment` model and builder support.
- Support multiple attachment entries.
- Document supported formats and limits.

### Tests

- Unit tests for attachment encoding and validation.
- Integration test to confirm XML structure.

### Acceptance Criteria

- Attachments are included and validate against XSD.

## 4) Multi-signature support

### Goal

Allow multiple signatures in a single invoice document.

### Design Notes

- Multiple `Signature` elements must be handled deterministically.
- Consider signature ordering and reference targets.

### Implementation Steps

- Add a signing API that accepts multiple signer configurations.
- Update signer to append signatures rather than overwrite.
- Add tests for multiple signature outputs.

### Tests

- Integration test with two signers and distinct certificates.

### Acceptance Criteria

- XML contains multiple valid signatures with distinct IDs.

## 5) CLI tool for signing invoices

### Goal

Provide a CLI wrapper for signing and validation.

### Design Notes

- Implement under `bin/` with clear usage and options.
- Support signing, validation, and schema checks.

### Implementation Steps

- Add CLI entrypoint and option parsing.
- Document usage in README.
- Add basic smoke tests for CLI output.

### Tests

- CLI smoke tests that sign a fixture and validate output.

### Acceptance Criteria

- CLI can sign an invoice and write output file deterministically.
