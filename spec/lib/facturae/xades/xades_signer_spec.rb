# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe XadesSigner do
      let(:xml) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae">
          </fe:Facturae>
        XML
      end
      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
      let(:certificate) { OpenSSL::X509::Certificate.new }
      let(:signer) { Xades::XadesSigner.new(xml_doc, private_key, certificate) }

      describe "#initialize" do
        it "initializes with the expected attributes" do
          expect(signer.xml_doc).to eq(xml_doc)
        end
      end

      describe "#sign" do
        before do
          allow_any_instance_of(Utils).to receive(:rand_id).and_return("random-uuid-12345")
        end

        it "adds a signature node to the XML document" do
          signer.sign

          expect(xml_doc.root.at_xpath("ds:Signature")).not_to be_nil
          expect(xml_doc.root.at_xpath("ds:Signature")["Id"]).to eq("Signaturerandom-uuid-12345")
          expect(xml_doc.root.at_xpath("ds:Signature")["xmlns:xades"]).to eq("http://uri.etsi.org/01903/v1.3.2#")
        end
      end
    end
  end
end
