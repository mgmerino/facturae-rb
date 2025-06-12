# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe ObjectInfo do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae"
                      xmlns:xades="http://uri.etsi.org/01903/v1.3.2#">
          </fe:Facturae>
        XML
      end

      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:ids) do
        {
          signature_id: "Signature",
          signed_properties_id: "SignedProperties-ID-1234",
          signature_object_id: "Object-ID-1234",
          reference_id: "Reference-ID-1234"
        }
      end
      let(:certificate) { OpenSSL::X509::Certificate.new(File.read("spec/fixtures/certificate.pem")) }
      let(:object_info) { ObjectInfo.new(xml_doc, certificate, ids) }

      describe "#build" do
        before do
          allow_any_instance_of(Utils).to receive(:rand_id).and_return("random-uuid-12345")
        end

        it "builds the XadesObject element with the correct structure" do
          result = xml_doc.root.add_child(object_info.build)

          expect(result.name).to eq("Object")
          expect(result["Id"]).to eq("Object-ID-1234")
          expect(result.at_xpath(".//xades:QualifyingProperties")["Target"]).to eq("##{ids[:signature_id]}")
          expect(result.at_xpath(".//xades:QualifyingProperties/xades:SignedProperties")["Id"]).to eq(ids[:signed_properties_id])
        end

        it "builds the SignedSignatureProperties element with the correct structure" do
          result = xml_doc.root.add_child(object_info.build)
          signed_signature_properties = result.at_xpath(".//xades:SignedSignatureProperties")

          expect(signed_signature_properties).not_to be_nil
          expect(signed_signature_properties.at_xpath(".//xades:SigningTime").text)
            .to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
          expect(signed_signature_properties.at_xpath(".//xades:SigningCertificate")).not_to be_nil
          expect(signed_signature_properties.at_xpath(".//xades:SignaturePolicyIdentifier")).not_to be_nil
          expect(signed_signature_properties.at_xpath(".//xades:SignerRole")).not_to be_nil
        end

        it "builds the SigningCertificate element with the correct structure" do
          result = xml_doc.root.add_child(object_info.build)
          signing_certificate = result.at_xpath(".//xades:SigningCertificate")

          expect(signing_certificate).not_to be_nil
          cert_node = signing_certificate.at_xpath(".//xades:Cert")
          expect(cert_node).not_to be_nil
          expect(cert_node.at_xpath(".//xades:CertDigest")).not_to be_nil
          expect(cert_node.at_xpath(".//xades:IssuerSerial")).not_to be_nil
        end

        it "builds the CertDigest element with the correct structure" do
          result = xml_doc.root.add_child(object_info.build)
          cert_digest = result.at_xpath(".//xades:CertDigest")

          expect(cert_digest).not_to be_nil
          expect(cert_digest.at_xpath(".//ds:DigestMethod")["Algorithm"]).to eq("http://www.w3.org/2001/04/xmlenc#sha512")
        end
      end
    end
  end
end
