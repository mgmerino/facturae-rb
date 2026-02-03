# Roadmap Implementation Plan

This document is the master plan for executing the roadmap in `README.md`.
It links to detailed plans per priority tier and describes sequencing,
dependencies, risks, and completion criteria.

## Goals

- Deliver the roadmap items in priority order with small, reviewable PRs.
- Preserve backward compatibility unless explicitly documented.
- Improve standards compliance and operational safety (signing, validation).
- Maintain test coverage via TDD for all new behaviors.

## Non-goals

- Redesigning the public API beyond what is required for roadmap items.
- Supporting non-Facturae or non-XAdES standards.
- Building a full invoicing application (this remains a library).

## Roadmap Mapping

- High Priority plan: `docs/roadmap/high-priority.md`
- Medium Priority plan: `docs/roadmap/medium-priority.md`
- Low Priority plan: `docs/roadmap/low-priority.md`

## Sequencing Strategy

1) High Priority
   - Complete gemspec metadata first (release readiness).
   - Add integration test with real certificate (baseline confidence).
   - Validate signed XML with the official Facturae validator.

2) Medium Priority
   - Upgrade signing to SHA256 (cryptography baseline).
   - Make signer role configurable (compatibility).
   - Add certificate expiration check (safety guard).
   - Add XML Schema validation (standards compliance).
   - Add invoice totals auto-calculation (usability).

3) Low Priority
   - XAdES-T timestamping.
   - Payment information models.
   - Attachment support.
   - Multi-signature support.
   - CLI tool for signing.

## Cross-cutting Dependencies

- Facturae 3.2.2 XSD must be available and versioned for validation.
- XAdES algorithm URIs and canonicalization must remain consistent.
- Test certificates must stay in `spec/fixtures/` only.
- Any API additions must be documented in README and CHANGELOG.

## Risks and Mitigations

- Validator integration may require manual or semi-automated steps.
  Mitigation: document a deterministic validation checklist and keep a
  stable signed XML fixture.
- SHA256 changes may break compatibility with legacy validators.
  Mitigation: support configuration for algorithm selection and keep
  SHA1 as optional, deprecated path.
- XML Schema validation may be slow for large invoices.
  Mitigation: make validation explicit or optional in API.

## Definition of Done

- All roadmap items are implemented or explicitly deferred with rationale.
- Tests cover new behaviors (unit and integration as appropriate).
- README and CHANGELOG reflect all user-facing changes.
- Signed XML validates against the Facturae validator (documented evidence).

## Maintenance

- Keep these plan documents aligned with the roadmap in `README.md`.
- Do not update the state roadmap document without explicit approval.
