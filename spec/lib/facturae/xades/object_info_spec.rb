# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe ObjectInfo do
      let(:xml) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae"
                      xmlns:xades="http://uri.etsi.org/01903/v1.3.2#">
          </fe:Facturae>
        XML
      end

      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:signature_id) { "Signature#{}" }
      let(:sp_id) { "SignedProperties-ID-#{}" }
      let(:object_id) { "Object-ID-#{}" }
      let(:ref_doc_id) { "Reference-ID-#{}" }
      let(:certificate) { OpenSSL::X509::Certificate.new(File.read("spec/fixtures/certificate.pem")) }
      let(:options) { {} }
      let(:object_info) { ObjectInfo.new(xml_doc, signature_id, sp_id, object_id, ref_doc_id, certificate, options) }

      describe "#build" do
        before do
          allow_any_instance_of(Utils).to receive(:rand_id).and_return("random-uuid-12345")
        end

        it "builds the XadesObject element with the correct structure" do
          # signature_node = xml_doc.at_xpath(".//ds:Signature")
          # result = signature_node.add_child(object_info.build)
          result = xml_doc.root.add_child(object_info.build)

          expect(result.name).to eq("Object")
          expect(result["Id"]).to eq(object_id)
          expect(result.at_xpath(".//xades:QualifyingProperties")["Target"]).to eq("##{signature_id}")
          expect(result.at_xpath(".//xades:QualifyingProperties/xades:SignedProperties")["Id"]).to eq(sp_id)
        end
      end
    end
  end
end
