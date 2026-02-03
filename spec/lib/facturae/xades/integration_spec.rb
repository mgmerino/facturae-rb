# frozen_string_literal: true

require "openssl"

# rubocop:disable Metrics/ModuleLength
module Facturae
  module Xades
    RSpec.describe "XAdES Integration" do
      let(:private_key) { OpenSSL::PKey::RSA.new(File.read("spec/fixtures/private_key.pem")) }
      let(:certificate) { OpenSSL::X509::Certificate.new(File.read("spec/fixtures/certificate.pem")) }

      let(:seller_party) do
        Party.new(
          person_type_code: "J",
          residence_type_code: "R",
          tax_id_number: "B12345678",
          subject: Subject.new(
            type: :legal,
            name_field1: "Test Company SL",
            name_field2: "Test Company",
            address_in_spain: Address.new(
              address: "Calle Mayor, 1",
              post_code: "28001",
              town: "Madrid",
              province: "Madrid",
              country_code: "ESP"
            )
          )
        )
      end

      let(:buyer_party) do
        Party.new(
          person_type_code: "F",
          residence_type_code: "R",
          tax_id_number: "12345678A",
          subject: Subject.new(
            type: :individual,
            name_field1: "Juan",
            name_field2: "García",
            name_field3: "López",
            address_in_spain: Address.new(
              address: "Calle Menor, 2",
              post_code: "28002",
              town: "Madrid",
              province: "Madrid",
              country_code: "ESP"
            )
          )
        )
      end

      let(:file_header) do
        FileHeader.new(
          modality: "I",
          invoice_issuer_type: "EM",
          batch: {
            invoices_count: 1,
            series_invoice_number: "2025/001",
            total_invoice_amount: 121.0,
            total_tax_outputs: 21.0,
            total_tax_inputs: 0.0,
            invoice_currency_code: "EUR"
          }
        )
      end

      let(:invoice) do
        inv = Invoice.new(
          invoice_header: {
            invoice_number: "001",
            invoice_series_code: "2025",
            invoice_document_type: "FC",
            invoice_class: "OO"
          },
          issue_data: {
            issue_date: Date.new(2025, 1, 15),
            invoice_currency_code: "EUR",
            tax_currency_code: "EUR",
            language_name: "es"
          }
        )

        inv.add_invoice_line(
          Line.new(
            item_description: "Professional services",
            quantity: 1.0,
            unit_price_without_tax: 100.0,
            total_cost: 100.0
          )
        )

        inv.add_tax_output(
          Tax.new(
            tax_type_code: "01",
            tax_rate: 21.0,
            taxable_base: 100.0,
            tax_amount: 21.0
          )
        )

        inv.totals = {
          total_gross_amount: 100.0,
          total_taxes_outputs: 21.0,
          total_taxes_withheld: 0.0,
          invoice_total: 121.0,
          total_outstanding_amount: 121.0,
          total_executable_amount: 121.0
        }

        inv
      end

      let(:document) do
        doc = FacturaeDocument.new(
          file_header: file_header,
          seller_party: seller_party,
          buyer_party: buyer_party
        )
        doc.add_invoice(invoice)
        doc
      end

      describe "end-to-end signing" do
        let(:xml) { FacturaeBuilder.new(document).to_xml }
        let(:xml_doc) { Nokogiri::XML(xml) }
        let(:signer) { Signer.new(xml_doc, private_key, certificate) }

        before do
          signer.sign
        end

        it "adds ds:Signature element to the document" do
          signature = xml_doc.at_xpath("//ds:Signature", Signer::NAMESPACES)
          expect(signature).not_to be_nil
        end

        it "includes SignedInfo with three references" do
          signed_info = xml_doc.at_xpath("//ds:SignedInfo", Signer::NAMESPACES)
          expect(signed_info).not_to be_nil

          references = signed_info.xpath(".//ds:Reference", Signer::NAMESPACES)
          expect(references.size).to eq(3)
        end

        it "includes DigestValue elements in SignedInfo references" do
          signed_info = xml_doc.at_xpath("//ds:SignedInfo", Signer::NAMESPACES)
          references = signed_info.xpath(".//ds:Reference", Signer::NAMESPACES)

          # Each reference should have a DigestValue element
          references.each do |ref|
            digest_value = ref.at_xpath(".//ds:DigestValue", Signer::NAMESPACES)
            expect(digest_value).not_to be_nil
          end

          # The document reference (the one with Transforms) should have a non-empty digest
          doc_ref = references.find { |r| r.at_xpath(".//ds:Transforms", Signer::NAMESPACES) }
          expect(doc_ref).not_to be_nil
          doc_digest = doc_ref.at_xpath(".//ds:DigestValue", Signer::NAMESPACES)
          expect(doc_digest.content).not_to be_empty
          expect { Base64.strict_decode64(doc_digest.content) }.not_to raise_error
        end

        it "includes non-empty SignatureValue element" do
          signature_value = xml_doc.at_xpath("//ds:SignatureValue", Signer::NAMESPACES)
          expect(signature_value).not_to be_nil
          expect(signature_value.content).not_to be_empty
          expect { Base64.strict_decode64(signature_value.content) }.not_to raise_error
        end

        it "includes KeyInfo with certificate" do
          key_info = xml_doc.at_xpath("//ds:KeyInfo", Signer::NAMESPACES)
          expect(key_info).not_to be_nil

          x509_cert = key_info.at_xpath(".//ds:X509Certificate", Signer::NAMESPACES)
          expect(x509_cert).not_to be_nil
          expect(x509_cert.content).not_to be_empty
        end

        it "includes XAdES QualifyingProperties" do
          qualifying_props = xml_doc.at_xpath("//xades:QualifyingProperties", Signer::NAMESPACES)
          expect(qualifying_props).not_to be_nil
        end

        it "includes SignedSignatureProperties" do
          signed_sig_props = xml_doc.at_xpath("//xades:SignedSignatureProperties", Signer::NAMESPACES)
          expect(signed_sig_props).not_to be_nil

          signing_time = signed_sig_props.at_xpath(".//xades:SigningTime", Signer::NAMESPACES)
          expect(signing_time).not_to be_nil
          expect(signing_time.content).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
        end

        it "includes SigningCertificate with digest" do
          signing_cert = xml_doc.at_xpath("//xades:SigningCertificate", Signer::NAMESPACES)
          expect(signing_cert).not_to be_nil

          cert_digest = signing_cert.at_xpath(".//xades:CertDigest/ds:DigestValue", Signer::NAMESPACES)
          expect(cert_digest).not_to be_nil
          expect(cert_digest.content).not_to be_empty
        end

        it "produces valid XML that can be parsed" do
          signed_xml = xml_doc.to_xml
          reparsed = Nokogiri::XML(signed_xml)
          expect(reparsed.errors).to be_empty
        end

        it "preserves the original Facturae structure" do
          fe_ns = { "fe" => "http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml" }
          facturae = xml_doc.at_xpath("//fe:Facturae", fe_ns)
          expect(facturae).not_to be_nil

          file_header_elem = facturae.at_xpath("fe:FileHeader", fe_ns)
          expect(file_header_elem).not_to be_nil

          invoices_elem = facturae.at_xpath("fe:Invoices", fe_ns)
          expect(invoices_elem).not_to be_nil
        end
      end

      describe "signature consistency" do
        it "produces different signatures for different documents" do
          xml1 = FacturaeBuilder.new(document).to_xml
          doc1 = Nokogiri::XML(xml1)
          Signer.new(doc1, private_key, certificate).sign
          sig1 = doc1.at_xpath("//ds:SignatureValue", Signer::NAMESPACES).content

          # Create a slightly different document
          document2 = FacturaeDocument.new(
            file_header: file_header,
            seller_party: seller_party,
            buyer_party: buyer_party
          )
          invoice2 = Invoice.new(
            invoice_header: {
              invoice_number: "002",
              invoice_series_code: "2025",
              invoice_document_type: "FC",
              invoice_class: "OO"
            },
            issue_data: {
              issue_date: Date.new(2025, 1, 16),
              invoice_currency_code: "EUR",
              tax_currency_code: "EUR",
              language_name: "es"
            }
          )
          invoice2.add_invoice_line(
            Line.new(
              item_description: "Other services",
              quantity: 2.0,
              unit_price_without_tax: 50.0,
              total_cost: 100.0
            )
          )
          invoice2.add_tax_output(
            Tax.new(
              tax_type_code: "01",
              tax_rate: 21.0,
              taxable_base: 100.0,
              tax_amount: 21.0
            )
          )
          invoice2.totals = {
            total_gross_amount: 100.0,
            total_taxes_outputs: 21.0,
            total_taxes_withheld: 0.0,
            invoice_total: 121.0,
            total_outstanding_amount: 121.0,
            total_executable_amount: 121.0
          }
          document2.add_invoice(invoice2)

          xml2 = FacturaeBuilder.new(document2).to_xml
          doc2 = Nokogiri::XML(xml2)
          Signer.new(doc2, private_key, certificate).sign
          sig2 = doc2.at_xpath("//ds:SignatureValue", Signer::NAMESPACES).content

          expect(sig1).not_to eq(sig2)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
