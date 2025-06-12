# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe Utils do
      let(:dummy_class) { Class.new { extend Utils } }
      let(:xml_doc) { Nokogiri::XML::Document.new }

      describe ".rand_id" do
        it "returns a random UUID" do
          expect(dummy_class.rand_id).to match(
            /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/
          )
        end
      end

      describe ".base64_encode" do
        it "encodes data to Base64 with SHA512 digest" do
          data = "These are not the droids you are looking for"
          encoded_data = dummy_class.base64_encode(data)
          expect(encoded_data).to eq(Base64.strict_encode64(OpenSSL::Digest::SHA512.digest(data)))
        end
      end

      describe ".base64_encode_raw" do
        it "encodes data to Base64 without digest" do
          data = "These are not the droids you are looking for"
          encoded_data = dummy_class.base64_encode_raw(data)
          expect(encoded_data).to eq(Base64.strict_encode64(data))
        end

        it "handles binary data correctly" do
          binary_data = "\x00\x01\x02\x03"
          encoded_data = dummy_class.base64_encode_raw(binary_data)
          expect(encoded_data).to eq(Base64.strict_encode64(binary_data))
        end
      end

      describe ".calculate_sha512_digest" do
        it "calculates SHA512 digest of data" do
          data = "These are not the droids you are looking for"
          digest = dummy_class.calculate_sha512_digest(data)
          expect(digest).to eq(OpenSSL::Digest::SHA512.digest(data))
        end

        it "returns different digests for different data" do
          data1 = "These are not the droids you are looking for"
          data2 = "Move along"
          digest1 = dummy_class.calculate_sha512_digest(data1)
          digest2 = dummy_class.calculate_sha512_digest(data2)
          expect(digest1).not_to eq(digest2)
        end
      end

      describe ".create_xml_element" do
        it "creates an element with the given name" do
          element = dummy_class.create_xml_element(xml_doc, "test")
          expect(element.name).to eq("test")
        end

        it "creates an element with content" do
          element = dummy_class.create_xml_element(xml_doc, "test", "content")
          expect(element.text).to eq("content")
        end

        it "creates an element with attributes" do
          element = dummy_class.create_xml_element(xml_doc, "test", nil, { "id" => "123", "type" => "example" })
          expect(element["id"]).to eq("123")
          expect(element["type"]).to eq("example")
        end

        it "creates an element with both content and attributes" do
          element = dummy_class.create_xml_element(xml_doc, "test", "content", { "id" => "123" })
          expect(element.text).to eq("content")
          expect(element["id"]).to eq("123")
        end
      end

      describe ".create_xml_node_with_algorithm" do
        it "creates a node with Algorithm attribute" do
          algorithm = "http://example.com/algorithm"
          element = dummy_class.create_xml_node_with_algorithm(xml_doc, "test", algorithm)
          expect(element.name).to eq("test")
          expect(element["Algorithm"]).to eq(algorithm)
        end

        it "creates a node without content" do
          element = dummy_class.create_xml_node_with_algorithm(xml_doc, "test", "algo")
          expect(element.text).to be_empty
        end
      end
    end
  end
end
