# Facturae

A Ruby gem for generating electronic invoices following the **Facturae 3.2.2** (06/06/2017) Spanish standard, with XAdES-BES digital signature support.

> **Status:** Work in progress - Core functionality is implemented but some features are incomplete.

## Purpose and Overview

This gem provides:
- Generation of electronic invoices according to the Facturae 3.2.2 XML schema
- Model-based validation of invoice data
- XAdES-BES (XML Advanced Electronic Signatures - Basic Electronic Signature) digital signing
- Support for multiple tax types (IVA, IRPF, IGIC, etc.)
- Discounts and charges at line level

### What is Facturae?

Facturae is the Spanish electronic invoicing standard mandated by the Spanish government for invoices to public administrations. The format is defined by the Spanish Ministry of Finance and uses XML with optional XAdES digital signatures.

## Architecture

```
lib/facturae/
├── models/           # Data models with validation
│   ├── facturae_document.rb   # Root document container
│   ├── file_header.rb         # Document metadata (schema, modality, batch info)
│   ├── invoice.rb             # Invoice with header, lines, taxes, totals
│   ├── line.rb                # Invoice line items
│   ├── party.rb               # Seller/buyer with tax identification
│   ├── subject.rb             # Individual or legal entity details
│   ├── address.rb             # Spanish or overseas address
│   └── tax.rb                 # Tax information (IVA, IRPF, etc.)
│
├── builders/         # XML generation (Builder pattern)
│   ├── facturae_builder.rb    # Main orchestrator
│   ├── file_header_builder.rb # FileHeader section
│   ├── parties_builder.rb     # Parties section
│   └── invoices_builder.rb    # Invoices section
│
└── xades/            # XAdES digital signature
    ├── signer.rb              # Main signing class
    ├── signed_info.rb         # SignedInfo element builder
    ├── key_info.rb            # KeyInfo element builder
    ├── object_info.rb         # QualifyingProperties builder
    └── utils.rb               # Shared utilities
```

### Flow

```
1. Create FacturaeDocument
   ├── Set FileHeader (schema version, modality, batch)
   ├── Set Parties (seller and buyer)
   └── Add Invoice(s)
       ├── Set header, issue data
       ├── Add line items
       ├── Add taxes
       └── Set totals

2. Validate → document.valid?()

3. Generate XML → FacturaeBuilder.new(document).to_xml()

4. [Optional] Sign → Signer.new(xml_doc, private_key, cert).sign()
```

## Installation

Add to your Gemfile:

```ruby
gem 'facturae'
```

Then run:

```bash
bundle install
```

## Usage

### Creating an Invoice

```ruby
require 'facturae'

# Create document
document = Facturae::FacturaeDocument.new(
  file_header: Facturae::FileHeader.new(
    modality: "I",
    invoice_issuer_type: "EM",
    batch: {
      invoices_count: 1,
      series_invoice_number: "2025/001",
      total_invoice_amount: 47.60,
      total_tax_outputs: 8.26,
      total_tax_inputs: 0.0,
      invoice_currency_code: "EUR"
    }
  ),
  seller_party: Facturae::Party.new(
    tax_identification: {
      person_type_code: "J",
      residence_type_code: "R",
      tax_identification_number: "B12345678"
    },
    subject: Facturae::Subject.new(
      type: :legal,
      name_field1: "Company SL",
      address_in_spain: Facturae::Address.new(
        address: "Calle Mayor, 1",
        post_code: "28001",
        town: "Madrid",
        province: "Madrid",
        country_code: "ESP"
      )
    )
  ),
  buyer_party: Facturae::Party.new(
    tax_identification: {
      person_type_code: "F",
      residence_type_code: "R",
      tax_identification_number: "12345678A"
    },
    subject: Facturae::Subject.new(
      type: :individual,
      name_field1: "Juan",
      name_field2: "García",
      address_in_spain: Facturae::Address.new(
        address: "Calle Menor, 2",
        post_code: "28002",
        town: "Madrid",
        province: "Madrid",
        country_code: "ESP"
      )
    )
  )
)

# Create invoice
invoice = Facturae::Invoice.new(
  invoice_header: {
    invoice_number: "001",
    invoice_series_code: "2025",
    invoice_document_type: "FC",
    invoice_class: "OO"
  },
  issue_data: {
    issue_date: Date.today,
    invoice_currency_code: "EUR",
    tax_currency_code: "EUR",
    language_name: "es"
  }
)

# Add line items
invoice.add_invoice_line(
  Facturae::Line.new(
    item_description: "Professional services",
    quantity: 10.0,
    unit_price_without_tax: 3.934,
    total_cost: 39.34
  )
)

# Add taxes
invoice.add_tax_output(
  Facturae::Tax.new(
    tax_type_code: "01",  # IVA
    tax_rate: 21.0,
    taxable_base: 39.34,
    tax_amount: 8.26
  )
)

# Set totals
invoice.totals = {
  total_gross_amount: 39.34,
  total_taxes_outputs: 8.26,
  total_taxes_withheld: 0.0,
  invoice_total: 47.60,
  total_outstanding_amount: 47.60,
  total_executable_amount: 47.60
}

document.add_invoice(invoice)

# Validate and generate XML
if document.valid?
  xml = Facturae::FacturaeBuilder.new(document).to_xml
  File.write("invoice.xml", xml)
end
```

### Signing an Invoice

```ruby
require 'openssl'

# Load certificate and private key
certificate = OpenSSL::X509::Certificate.new(File.read("certificate.pem"))
private_key = OpenSSL::PKey::RSA.new(File.read("private_key.pem"))

# Parse the XML
xml_doc = Nokogiri::XML(xml)

# Sign
signer = Facturae::Xades::Signer.new(xml_doc, private_key, certificate)
signer.sign

# Save signed invoice
File.write("invoice_signed.xml", xml_doc.to_xml)
```

---

## Pending / Unfinished Work

### XAdES Signature Implementation

The XAdES-BES implementation is **more complete than initially thought**. The core signing functionality works:

| Component | Status |
|-----------|--------|
| Signer class | Complete |
| SignedInfo with 3 references | Complete |
| KeyInfo (certificate, RSA key) | Complete |
| QualifyingProperties | Complete |
| Canonicalization (C14N) | Complete |
| RSA-SHA1 signing | Complete |
| Structure validation | Complete |

**Known limitations:**

1. **Hard-coded signature policy** (`object_info.rb:15-17`)
   - Policy URL and hash are fixed to Facturae standard
   - Not configurable for other policies

2. **Hard-coded signer role** (`object_info.rb:140`)
   - Always set to "supplier"
   - Should be configurable (buyer, issuer, etc.)

3. **SHA1 algorithm (deprecated)** (`signer.rb:40,161`)
   - Uses RSA-SHA1 for signing
   - Modern standards prefer SHA256/SHA512
   - May not be accepted by some validators

4. **No certificate validation**
   - No expiration check before signing
   - No revocation checking (CRL/OCSP)

5. **No XAdES-T/XAdES-XL support**
   - Only XAdES-BES profile implemented
   - No timestamp authority (TSA) integration
   - Not suitable for long-term archival

### Gemspec TODOs

The gemspec has placeholder values that need to be filled in before publishing:

```ruby
spec.summary     = "TODO: Write a short summary..."
spec.description = "TODO: Write a longer description..."
spec.homepage    = "TODO: Put your gem's website..."
spec.metadata["source_code_uri"] = "TODO: ..."
spec.metadata["changelog_uri"]   = "TODO: ..."
```

### Other Incomplete Features

1. **Invoice-level discounts/charges**
   - Line-level discounts added but not tested
   - No invoice-level discount support

2. **Payment information**
   - No payment terms, payment means, or bank account details

3. **Attachments**
   - No support for attached documents in invoice or signature

4. **Additional invoice types**
   - Corrective invoices partially supported
   - Summary invoices not implemented

5. **Validation gaps**
   - No XML Schema validation against official XSD
   - No cross-field validation (e.g., totals matching line sums)

---

## Improvements Roadmap

### High Priority

- [ ] Complete gemspec metadata
- [ ] Add integration test with real certificate
- [ ] Validate signed XML against Facturae validator

### Medium Priority

- [ ] Upgrade to SHA256 for signing (SHA1 is deprecated)
- [ ] Make signer role configurable
- [ ] Add certificate expiration check
- [ ] Add XML Schema validation
- [ ] Invoice total auto-calculation from lines

### Low Priority

- [ ] Support XAdES-T (timestamping)
- [ ] Payment information models
- [ ] Attachment support
- [ ] Multi-signature support
- [ ] CLI tool for signing invoices

---

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
