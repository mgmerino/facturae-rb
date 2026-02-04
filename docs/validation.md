# Facturae Signature Validation Guide

This document describes how to validate signed Facturae XML invoices generated
by this library.

## Overview

Facturae electronic invoices must be digitally signed using XAdES-BES (XML
Advanced Electronic Signatures - Basic Electronic Signature) format. This
library generates signatures compliant with the Facturae 3.2.2 specification.

## Validation Methods

### 1. Structural Validation (Local)

Use the included validation script to verify the XML structure:

```bash
bundle exec ruby bin/validate_signature spec/fixtures/signed_invoice.xml
```

This script checks:
- Facturae root element exists
- ds:Signature element exists
- SignedInfo with 3 References
- Non-empty SignatureValue
- X509Certificate is present and parseable
- XAdES QualifyingProperties (SigningTime, SigningCertificate, PolicyIdentifier)
- Document DigestValue is present

**Note:** This validates structure only, not cryptographic correctness.

### 2. Official FACe Validator (Recommended)

The Spanish Government provides an official validator at:
- **URL:** https://face.gob.es/es/facturas/validar-visualizar-facturas
- **New portal:** https://proveedores.face.gob.es

The FACe validator checks:
- Facturae format compliance
- Electronic signature validity
- Whether the invoice has already been submitted

**Requirements:**
- Digital certificate (DNIe, Cl@ve, or recognized certificate)
- Active internet connection

### 3. xmlsec1 Command Line Tool

For local cryptographic verification, use [xmlsec1](https://www.aleksey.com/xmlsec/):

```bash
# Install on Ubuntu/Debian
sudo apt-get install xmlsec1

# Verify signature
xmlsec1 --verify --trusted-pem cert.pem signed_invoice.xml
```

**Note:** xmlsec1 provides basic XML-DSig verification but may not fully support
all XAdES extensions.

### 4. Online XML Signature Validators

Several online tools can verify XML Digital Signatures:
- [Chilkat XML Signature Validator](https://tools.chilkat.io/xmlDsigVerify.cshtml)

## Test Fixture

A signed test invoice is available at:

```
spec/fixtures/signed_invoice.xml
```

This fixture was generated using the test certificate and private key in
`spec/fixtures/` and demonstrates a complete signed Facturae 3.2.2 invoice.

### Fixture Details

| Property | Value |
|----------|-------|
| Generated | 2026-02-03 |
| Facturae Version | 3.2.2 |
| Signature Format | XAdES-BES |
| Certificate | Test certificate (self-signed, not for production) |
| Invoice Number | 2025/001 |

### Regenerating the Fixture

```bash
bundle exec ruby bin/generate_signed_fixture
```

## Signature Structure

The XAdES-BES signature includes:

1. **SignedInfo** - Contains references to:
   - The signed document (enveloped signature)
   - The KeyInfo element
   - The SignedProperties (XAdES)

2. **SignatureValue** - RSA-SHA1 signature over canonicalized SignedInfo

3. **KeyInfo** - Contains:
   - X509Certificate (full certificate)
   - RSAKeyValue (public key components)

4. **XAdES QualifyingProperties**:
   - SigningTime (timestamp)
   - SigningCertificate (certificate digest)
   - SignaturePolicyIdentifier (Facturae v3.1 policy)
   - SignerRole (supplier)
   - DataObjectFormat (application/xml)

## Known Limitations

1. **Test Certificate**: The included certificate is self-signed and intended
   only for testing. Production invoices must use a recognized certificate
   from an accredited certification authority.

2. **FACe Submission**: To submit invoices to public administrations via FACe,
   you need a valid certificate recognized by the Spanish Government.

3. **XAdES Compliance**: The current implementation generates XAdES-BES
   signatures. Full XAdES-EPES compliance with the official Facturae policy
   may require additional validation.

## Validation Checklist

Before submitting invoices to FACe:

- [ ] XML validates against Facturae 3.2.2 XSD schema
- [ ] Digital signature is present and well-formed
- [ ] Certificate is valid and recognized
- [ ] All required invoice fields are populated
- [ ] Tax calculations are correct
- [ ] Invoice totals match line items

## References

- [Facturae Official Site](https://www.facturae.gob.es/)
- [FACe Portal](https://face.gob.es/)
- [Facturae 3.2.2 Schema](http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml)
- [Facturae Signature Policy v3.1](http://www.facturae.es/politica_de_firma_formato_facturae/politica_de_firma_formato_facturae_v3_1.pdf)
- [XAdES Specification (ETSI EN 319 132)](https://www.etsi.org/deliver/etsi_en/319100_319199/31913201/)
