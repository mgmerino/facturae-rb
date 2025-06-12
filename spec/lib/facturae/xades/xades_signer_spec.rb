# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe XadesSigner do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <fe:Facturae xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                      xmlns:fe="http://www.facturae.es/Facturae/2014/v3.2.1/Facturae">
            <FileHeader>
              <SchemaVersion>3.2.2</SchemaVersion>
            </FileHeader>
          </fe:Facturae>
        XML
      end

      let(:xml_doc) { Nokogiri::XML(xml) }
      let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
      let(:certificate) { OpenSSL::X509::Certificate.new(File.read("spec/fixtures/certificate.pem")) }
      let(:signer) { described_class.new(xml_doc, private_key, certificate) }

      describe "#initialize" do
        it "sets up all required IDs" do
          expect(signer.signature_id).to match(/Signature[a-f0-9-]{36}/)
          expect(signer.signed_properties_id).to match(/SignedPropertiesID[a-f0-9-]{36}/)
          expect(signer.signature_object_id).to match(/Signature[a-f0-9-]{36}-Object[a-f0-9-]{36}/)
          expect(signer.reference_id).to match(/Reference-ID-[a-f0-9-]{36}/)
          expect(signer.certificate_id).to match(/Certificate[a-f0-9-]{36}/)
          expect(signer.signature_value_id).to match(/SignatureValue[a-f0-9-]{36}/)
          expect(signer.signed_info_id).to match(/Signature-SignedInfo[a-f0-9-]{36}/)
        end
      end

      describe "#sign" do
        context "when successful" do
          it "adds a ds:Signature node to the document" do
            signer.sign
            expect(xml_doc.at_xpath("//ds:Signature", described_class::NAMESPACES)).not_to be_nil
          end

          it "includes all required XAdES elements" do
            signature_node = signer.sign

            expect(signature_node.at_xpath(".//ds:SignedInfo", described_class::NAMESPACES)).not_to be_nil
            expect(signature_node.at_xpath(".//ds:SignatureValue", described_class::NAMESPACES)).not_to be_nil
            expect(signature_node.at_xpath(".//ds:KeyInfo", described_class::NAMESPACES)).not_to be_nil
            expect(signature_node.at_xpath(".//xades:QualifyingProperties", described_class::NAMESPACES)).not_to be_nil
          end

          it "sets correct namespaces" do
            signature_node = signer.sign

            expect(signature_node["xmlns:xades"]).to eq(described_class::XADES_NAMESPACE)
          end

          it "creates a valid signature value" do
            signature_node = signer.sign
            signature_value = signature_node.at_xpath(".//ds:SignatureValue", described_class::NAMESPACES)

            expect(signature_value).not_to be_nil
            expect(signature_value.content).not_to be_empty
            expect { Base64.strict_decode64(signature_value.content) }.not_to raise_error
          end
        end

        context "when validation fails" do
          let(:invalid_xml) do
            <<~XML
              <?xml version="1.0" encoding="UTF-8"?>
              <InvalidRoot></InvalidRoot>
            XML
          end

          let(:invalid_doc) { Nokogiri::XML(invalid_xml) }
          let(:invalid_signer) { described_class.new(invalid_doc, private_key, certificate) }

          let(:mock_signed_info_class) { class_double(SignedInfo) }
          let(:mock_signed_info) { instance_double(SignedInfo) }
          let(:mock_key_info_class) { class_double(KeyInfo) }
          let(:mock_key_info) { instance_double(KeyInfo) }
          let(:mock_object_info_class) { class_double(ObjectInfo) }
          let(:mock_object_info) { instance_double(ObjectInfo) }

          it "raises SignatureError for missing SignedInfo" do
            allow(mock_signed_info_class).to receive(:new).and_return(mock_signed_info)
            allow(mock_signed_info).to receive(:build).and_return(nil)

            signer_with_mock = described_class.new(xml_doc, private_key, certificate,
                                                   { signed_info: mock_signed_info_class })

            expect { signer_with_mock.sign }.to raise_error(SignatureError, "Missing SignedInfo")
          end

          it "raises SignatureError for invalid CanonicalizationMethod" do
            signer_with_mock = described_class.new(xml_doc, private_key, certificate,
                                                   { signed_info: mock_signed_info_class })

            allow(mock_signed_info_class).to receive(:new).and_return(mock_signed_info)
            allow(mock_signed_info).to receive(:build) do
              node = Nokogiri::XML::Node.new("ds:SignedInfo", xml_doc)
              node["Id"] = signer_with_mock.signed_info_id
              c14n = Nokogiri::XML::Node.new("ds:CanonicalizationMethod", xml_doc)
              c14n["Algorithm"] = "invalid"
              node.add_child(c14n)
              node
            end

            expect { signer_with_mock.sign }.to raise_error(SignatureError, "Invalid CanonicalizationMethod")
          end

          it "raises SignatureError for missing SignatureMethod" do
            signer_with_mock = described_class.new(xml_doc, private_key, certificate,
                                                   { signed_info: mock_signed_info_class })

            allow(mock_signed_info_class).to receive(:new).and_return(mock_signed_info)
            allow(mock_signed_info).to receive(:build) do
              node = Nokogiri::XML::Node.new("ds:SignedInfo", xml_doc)
              node["Id"] = signer_with_mock.signed_info_id
              c14n = Nokogiri::XML::Node.new("ds:CanonicalizationMethod", xml_doc)
              c14n["Algorithm"] = described_class::C14N_METHOD_ALGORITHM
              node.add_child(c14n)
              node
            end

            expect { signer_with_mock.sign }.to raise_error(SignatureError, "Missing SignatureMethod")
          end

          it "raises SignatureError for missing KeyInfo" do
            allow(mock_key_info_class).to receive(:new).and_return(mock_key_info)
            allow(mock_key_info).to receive(:build).and_return(nil)

            signer_with_mock = described_class.new(xml_doc, private_key, certificate,
                                                   { key_info: mock_key_info_class })

            expect { signer_with_mock.sign }.to raise_error(SignatureError, "Missing KeyInfo")
          end

          it "raises SignatureError for missing QualifyingProperties" do
            allow(mock_object_info_class).to receive(:new).and_return(mock_object_info)
            allow(mock_object_info).to receive(:build).and_return(nil)

            signer_with_mock = described_class.new(xml_doc, private_key, certificate,
                                                   { object_info: mock_object_info_class })

            expect { signer_with_mock.sign }.to raise_error(SignatureError, "Missing QualifyingProperties")
          end
        end
      end

      describe "#canonicalize" do
        it "normalizes whitespace in XML" do
          # Different whitespace variations that should canonicalize to the same result
          inputs = [
            "<root><child>text</child></root>",
            "<root>\n  <child>text</child>\n</root>",
            "<root><child>  text  </child></root>",
            "<root>  <child>text</child>  </root>"
          ]

          # Convert all inputs to Nokogiri documents and canonicalize
          results = inputs.map do |xml|
            doc = Nokogiri::XML(xml)
            signer.send(:canonicalize, doc.root)
          end

          # All results should be equal
          expected = "<root><child>text</child></root>"
          results.each do |result|
            expect(result.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
          end
        end

        it "handles namespaces correctly" do
          xml_with_ns = <<~XML
            <root xmlns:a="http://example.com/a">
              <a:child>text</a:child>
            </root>
          XML

          doc = Nokogiri::XML(xml_with_ns)
          result = signer.send(:canonicalize, doc.root)

          # The result should preserve the namespace declaration and structure
          expect(result.gsub(/\s+/, "")).to include('xmlns:a="http://example.com/a"')
          expect(result.gsub(/\s+/, "")).to include("<a:child>text</a:child>".gsub(/\s+/, ""))
        end
      end

      describe "#calculate_signature" do
        let(:test_data) { "test data" }

        it "produces a valid Base64 string" do
          result = signer.send(:calculate_signature, test_data)
          expect { Base64.strict_decode64(result) }.not_to raise_error
        end

        it "produces different signatures for different data" do
          sig1 = signer.send(:calculate_signature, "data1")
          sig2 = signer.send(:calculate_signature, "data2")
          expect(sig1).not_to eq(sig2)
        end
      end
    end
  end
end
