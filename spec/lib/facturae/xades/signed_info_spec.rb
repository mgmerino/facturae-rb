# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe SignedInfo do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae">
          </fe:Facturae>
        XML
      end
      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:cert_id) { "Certificate#{rand_id}" }
      let(:ref_doc_id) { "Reference-ID-#{rand_id}" }
      let(:options) { {} }
      let(:signed_info) { SignedInfo.new(xml_doc, options) }

      describe "#build" do
        before do
          allow_any_instance_of(Utils).to receive(:rand_id).and_return("random-uuid-12345")
        end

        it "builds the SignedInfo element with the correct structure" do
          result = xml_doc.root.add_child(signed_info.build)

          expect(result.name).to eq("SignedInfo")
          expect(result.at_xpath("ds:CanonicalizationMethod")["Algorithm"]).to eq(SignedInfo::C14N_METHOD_ALGORITHM)
          expect(result.at_xpath("ds:SignatureMethod")["Algorithm"]).to eq(SignedInfo::SIGNATURE_METHOD_ALGORITHM)
          expect(result.xpath("ds:Reference").size).to eq(3)
        end
      end
    end
  end
end
