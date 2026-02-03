# High Priority Roadmap Plan

Scope: items listed under "High Priority" in `README.md`.

## 1) Complete gemspec metadata

### Goal

Ship a publishable gemspec with accurate metadata and links.

### Design Notes

- Update `facturae.gemspec` to include summary, description, homepage,
  and metadata URIs.
- Ensure values are consistent with README and repository URLs.
- Make a release mechanism using Github Actions

### Implementation Steps

- Identify canonical homepage and source code URLs.
- Replace all TODO values in `facturae.gemspec`.
- Update `CHANGELOG.md` if required by metadata.

### Tests

- Add or update spec coverage only if metadata is used by code paths.
- Run `bundle exec rake build` to ensure gemspec is valid.

### Acceptance Criteria

- No TODO placeholders remain in `facturae.gemspec`.
- `bundle exec rake build` succeeds.

## 2) Integration test with real certificate

### Goal

Verify end-to-end signing with a test certificate and known fixture data.

### Design Notes

- Use test-only certificate in `spec/fixtures/`.
- Keep private key in `spec/fixtures/` and ensure it is test-only.
- Create a canonical XML fixture for deterministic output.

### Implementation Steps

- Create an integration spec in `spec/lib/facturae/xades/`.
- Build a minimal invoice fixture (or reuse existing fixture).
- Sign the XML and assert:
  - Signature element exists.
  - Digest values are present and non-empty.
  - Signature value is present and non-empty.

### Tests

- `bundle exec rspec spec/lib/facturae/xades`.

### Acceptance Criteria

- Integration spec passes consistently.
- No real certificates are committed.

## 3) Validate signed XML against Facturae validator

### Goal

Demonstrate that signed XML complies with official validation tooling.

### Design Notes

- Prefer an automated check if the validator is accessible via CLI or API.
- If not automatable, document a manual validation checklist and keep a
  verified XML fixture with recorded validation evidence.

### Implementation Steps

- Research available validator access (CLI, desktop, or online portal).
- Add a `docs/` note describing how validation is performed.
- Store a signed XML fixture used for validation.
- Record the validation result (date, validator version) in docs.

### Tests

- If a validator CLI is available, add a non-blocking CI step or
  a local script in `bin/`.

### Acceptance Criteria

- There is a documented validation process.
- A signed XML fixture has been validated and referenced in docs.
