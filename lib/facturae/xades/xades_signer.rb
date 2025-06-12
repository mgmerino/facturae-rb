# frozen_string_literal: true

require_relative "signed_info"
require_relative "key_info"
require_relative "object_info"
require "openssl"
require "base64"

module Facturae
  module Xades
    # Handles the signing of XML documents using XAdES.
    class XadesSigner
      include Utils

      XADES_NAMESPACE = "http://uri.etsi.org/01903/v1.3.2#"
      C14N_METHOD_ALGORITHM = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
      SIGNATURE_METHOD_ALGORITHM = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"

      attr_reader :xml_doc, :signature_id, :signed_properties_id, :signature_object_id,
                  :reference_id, :certificate_id, :signature_value_id, :signed_info_id

      def initialize(xml_doc, private_key, certificate)
        @xml_doc = xml_doc
        @private_key = private_key
        @certificate = certificate

        @certificate_id = "Certificate#{rand_id}"
        @reference_id = "Reference-ID-#{rand_id}"
        @signature_id = "Signature#{rand_id}"
        @signature_object_id = "#{signature_id}-Object#{rand_id}"
        @signature_signed_properties_id = "#{signature_id}-SignedProperties#{rand_id}"
        @signature_value_id = "SignatureValue#{rand_id}"
        @signed_info_id = "Signature-SignedInfo#{rand_id}"
        @signed_properties_id = "SignedPropertiesID#{rand_id}"
      end

      def sign
        signature_node = build_signature_node
        @xml_doc.root.add_child(signature_node)

        # Add the SignedInfo element to the signature node
        signed_info = SignedInfo.new(@xml_doc, { signed_info_id: }).build
        signature_node.add_child(signed_info)

        # Canonicalize SignedInfo
        canonicalized_signed_info = canonicalize(signed_info)

        # Calculate the signature
        signature_value = calculate_signature(canonicalized_signed_info)

        # Add SignatureValue element
        signature_value_node = build_signature_value_node(signature_value)
        signature_node.add_child(signature_value_node)

        # Add the KeyInfo element to the signature node
        key_info = KeyInfo.new(@xml_doc, @certificate, { certificate_id: }).build
        signature_node.add_child(key_info)

        # Add the ObjectInfo element to the signature node
        object_info = ObjectInfo.new(@xml_doc, @certificate,
                                     { signature_id:, signed_properties_id:, signature_object_id:, reference_id: }).build
        signature_node.add_child(object_info)
      end

      private

      def build_signature_node
        signature = @xml_doc.create_element("ds:Signature")
        signature["Id"] = @signature_id
        signature["xmlns:xades"] = XADES_NAMESPACE

        signature
      end

      def canonicalize(node)
        # Create a new document containing only the node to canonicalize
        doc = Nokogiri::XML::Document.new
        doc.root = node.dup

        doc.canonicalize(Nokogiri::XML::XML_C14N_1_0)
      end

      def calculate_signature(canonicalized_data)
        digest = OpenSSL::Digest.new("SHA1")
        signature = @private_key.sign(digest, canonicalized_data)

        Base64.strict_encode64(signature)
      end

      def build_signature_value_node(signature_value)
        signature_value_node = @xml_doc.create_element("ds:SignatureValue", signature_value)
        signature_value_node["Id"] = @signature_value_id
        signature_value_node
      end

      def signing_ids
        {
          signature_id:,
          signed_properties_id:,
          signature_object_id:,
          reference_id:
        }
      end
    end
  end
end
