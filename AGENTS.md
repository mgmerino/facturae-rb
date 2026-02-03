# AGENTS.md

> Instructions for AI coding agents working on this project.
>
> This file follows the [AGENTS.md](https://agents.md) open standard and works with Claude Code, Cursor, Copilot, Codex, Jules, Windsurf, and other AI coding tools.

---

## Project Overview
A Ruby gem for generating electronic invoices following the **Facturae 3.2.2** (06/06/2017) Spanish standard, with XAdES-BES digital signature support.

This gem provides:
- Generation of electronic invoices according to the Facturae 3.2.2 XML schema
- Model-based validation of invoice data
- XAdES-BES (XML Advanced Electronic Signatures - Basic Electronic Signature) digital signing
- Support for multiple tax types (IVA, IRPF, IGIC, etc.)
- Discounts and charges at line level

---

## Quick Start

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Interactive console
bundle exec irb -r ./lib/facturae
```

---

## Workflow



### Key Principles

- **Small PRs**: Each PR solves exactly one issue
- **Atomic commits**: Each commit does one thing and passes all tests
- **Test-Driven Development**: Write tests first (RED), make them pass (GREEN), then refactor
- **Refactor first**: Preparation commits before feature commits
- **Working software**: Every commit is deployable
- **Simplicity**: YAGNI—don't over-engineer

### Task Completion

After completing a task or sprint:

1. **Always ask permission first** - Never update the roadmap without explicit human approval
2. **Request roadmap update** - Ask the human if you should update `docs/how-to-work/roadmap.md`
3. **What to update** (if permission granted):
   - Move completed tasks from "In Progress" or "Up Next" to the "Completed" section
   - Include task ID, description, PR number, and completion date
   - Remove tasks from "In Progress" section if they were listed there
   - For sprints, summarize what was completed

The roadmap is a state document that must stay current, but updates require human oversight.

---

## Commands

### Development

```bash
bundle install          # Install dependencies
bundle exec irb -r ./lib/facturae  # Interactive console with gem loaded
bundle exec rake build  # Build the gem
```

### Testing

```bash
bundle exec rspec                           # Run all tests
bundle exec rspec spec/lib/facturae/models  # Run model tests only
bundle exec rspec spec/lib/facturae/xades   # Run XAdES tests only
bundle exec rspec --format documentation    # Verbose output
bundle exec rspec path/to/spec.rb:42        # Run specific test by line
```

### Linting & Formatting

```bash
bundle exec rubocop                # Run linter
bundle exec rubocop -a             # Auto-fix safe issues
bundle exec rubocop -A             # Auto-fix all issues (use with caution)
bundle exec rubocop --only Style   # Run only style cops
```

---

## Code Style

### General

- Prefer clarity over cleverness
- Keep functions small and focused
- Write self-documenting code
- Comment *why*, not *what*

### Naming

- Variables: `snake_case`
- Methods: `snake_case`
- Classes: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Files: `snake_case.rb`

### Imports

Ruby doesn't use imports, but follow Rails conventions:
1. Standard library
2. External gems
3. Application code (app/)
4. Concerns and modules

---

## Git Conventions

### Branches

```
feature/issue-{number}-{short-description}
fix/issue-{number}-{short-description}
refactor/{description}
docs/{description}
```

### Commit Messages

```
type(scope): description

Types: feat, fix, refactor, test, docs, chore
```

### Commit Sequence

When implementing a feature using TDD, follow this order:

1. `refactor`: Prepare codebase for changes (all tests GREEN)
2. `test`: Add failing test for next requirement (RED)
3. `feat`/`fix`: Implement code to pass test (GREEN)
4. `refactor`: Clean up code (still GREEN)
5. Repeat steps 2-4 for each requirement
6. `docs`: Update documentation

Each GREEN commit must pass all tests. RED commits may have failing tests (the new ones only).

### Pull Requests

- Title: `[TYPE] Brief description (#issue)`
- Link to the issue being solved
- Include brief description of approach
- Keep PRs small and focused (<400 lines changed)

---

## Testing

This project uses **Test-Driven Development (TDD)** for building features. See `docs/how-to-work/tdd.md` for detailed guidance.

### TDD Cycle

```
RED → GREEN → REFACTOR
```

1. **RED**: Write a failing test
2. **GREEN**: Write simplest code to pass
3. **REFACTOR**: Clean up while keeping tests green

### What to Test

- Business logic and data transformations
- Edge cases and error handling
- Public APIs and interfaces
- Integration points

### Test Naming

Use descriptive names:

```
Good: it 'returns empty list when no items match filter'
Bad:  it 'works correctly'
```

### RSpec Patterns

- Use `describe` for classes/modules
- Use `context` for scenarios
- Use `let` for lazy evaluation
- Use `let!` only when necessary
- Use factories (FactoryBot) for test data

---

## Architecture

Brief overview of system structure. See `docs/how-to-work/architecture.md` for details.

### Key Directories

```
lib/facturae/
├── models/           # Data models with validation
│   ├── facturae_document.rb   # Root container (file_header, parties, invoices)
│   ├── file_header.rb         # Schema version, modality, batch info
│   ├── invoice.rb             # Invoice with header, lines, taxes, totals
│   ├── line.rb                # Line items with discounts/charges
│   ├── party.rb               # Seller/buyer with tax identification
│   ├── subject.rb             # Individual or legal entity
│   ├── address.rb             # Spanish or overseas address
│   └── tax.rb                 # Tax info (IVA, IRPF, etc.)
│
├── builders/         # XML generation (Builder pattern)
│   ├── facturae_builder.rb    # Main orchestrator → to_xml()
│   ├── file_header_builder.rb # <FileHeader> section
│   ├── parties_builder.rb     # <Parties> section
│   └── invoices_builder.rb    # <Invoices> section
│
└── xades/            # XAdES-BES digital signature
    ├── signer.rb              # Main signing class
    ├── signed_info.rb         # <SignedInfo> with 3 references
    ├── key_info.rb            # <KeyInfo> with certificate
    ├── object_info.rb         # <QualifyingProperties>
    └── utils.rb               # Digest, Base64, XML utilities

spec/                 # RSpec tests (mirrors lib/ structure)
```

### Important Patterns

1. **Builder Pattern** - XML generation separated from models
   - Models hold data and validation logic
   - Builders transform models to XML
   - `FacturaeBuilder` orchestrates sub-builders

2. **Model Validation** - Each model has a `valid?` method
   - Validates types, required fields, allowed values
   - `FacturaeDocument#valid?` recursively validates children

3. **Dependency Injection** - XAdES Signer accepts builder classes
   - Enables testing with mock builders
   - Example: `Signer.new(doc, key, cert, { signed_info: MockSignedInfo })`

4. **Constants for Allowed Values** - Enums defined as class constants
   - `Party::LEGAL_ENTITY`, `Party::NATURAL_PERSON`
   - `Tax::IVA`, `Tax::IRPF`, etc.

---

## Security Considerations

- **Certificate Handling**: Never commit real certificates or private keys
  - Use `spec/fixtures/` for test certificates only
  - Real certificates should be loaded from environment or secure storage

- **XAdES Signing**: Currently uses RSA-SHA1 (deprecated)
  - SHA1 is considered weak; plan to upgrade to SHA256
  - Validate certificates before signing (expiration, revocation)

- **Input Validation**: Always validate user input before building invoices
  - Tax identification numbers should be validated
  - Monetary amounts should be sanitized

- **XML Security**: Nokogiri handles XML parsing safely by default
  - External entity processing is disabled
  - Be cautious with user-provided XML content

---

## When Stuck

1. **Check the Facturae 3.2.2 Schema**
   - Official XSD defines all required/optional fields
   - Field names must match exactly (case-sensitive)

2. **XAdES Signature Issues**
   - Verify certificate format (PEM, DER)
   - Check that private key matches certificate
   - Canonicalization must be exact (C14N)
   - Reference URIs must match element IDs

3. **Validation Failures**
   - Each model's `valid?` method checks types strictly
   - Floats required for monetary values (use `10.0` not `10`)
   - Check constants for allowed values (tax codes, country codes)

4. **XML Output Differences**
   - Compare with `spec/fixtures/test_invoice.xml`
   - Use `nokogiri` to pretty-print and diff XML

5. **Test Fixtures**
   - `spec/fixtures/certificate.pem` - Test X509 certificate
   - `spec/fixtures/private_key.pem` - Test RSA private key

---

## Additional Resources

- [Facturae Official Site](https://www.facturae.gob.es/) - Spanish government portal
- [Facturae 3.2.2 Schema](https://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml) - XML namespace/schema
- [XAdES Specification (ETSI TS 101 903)](https://www.etsi.org/deliver/etsi_ts/101900_101999/101903/) - XAdES standard
- [Nokogiri Documentation](https://nokogiri.org/) - XML processing library
- [OpenSSL Ruby Docs](https://ruby-doc.org/stdlib/libdoc/openssl/rdoc/OpenSSL.html) - Certificate and signing APIs
