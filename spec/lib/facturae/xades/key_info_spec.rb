# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe KeyInfo do
      let(:xml) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae">
          </fe:Facturae>
        XML
      end
      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:certificate) { OpenSSL::X509::Certificate.new(File.read("spec/fixtures/certificate.pem")) }
      let(:options) { {} }
      let(:key_info) { described_class.new(xml_doc, certificate, options) }

      describe "#build" do
        it "builds the KeyInfo element" do
          result = xml_doc.root.add_child(key_info.build)

          expect(result.name).to eq("KeyInfo")
        end

        it "includes the KeyValue element with the correct modulus and exponent" do
          result = xml_doc.root.add_child(key_info.build)

          expect(result.at_xpath("ds:KeyValue/ds:RSAKeyValue/ds:Modulus").text)
            .to eq(Base64.strict_encode64(certificate.public_key.n.to_s(2)))

          expect(result.at_xpath("ds:KeyValue/ds:RSAKeyValue/ds:Exponent").text)
            .to eq(Base64.strict_encode64(certificate.public_key.e.to_s(2)))
        end

        it "includes the X509Data element with the correct certificate" do
          result = xml_doc.root.add_child(key_info.build)

          expect(result.at_xpath("ds:X509Data/ds:X509Certificate").text)
            .to eq(Base64.strict_encode64(certificate.to_der))
        end

        it "assigns a unique Id to the KeyInfo element" do
          result = xml_doc.root.add_child(key_info.build)

          expect(result["Id"]).to match(/Certificate[a-f0-9-]{36}/)
        end
      end
    end
  end
end
