# frozen_string_literal: true

require "openssl"
require "base64"

module Facturae
  module Xades
    # Handles the building of the SignedInfo element for XAdES signatures.
    # This class is responsible for creating the SignedInfo element that contains
    # references to all signed content, including the document itself, the certificate,
    # and the signed properties.
    class SignedInfo
      include Utils

      C14N_METHOD_ALGORITHM = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
      SIGNATURE_METHOD_ALGORITHM = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha512"
      TRANSFORM_ALGORITHM = "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
      DIGEST_METHOD_ALGORITHM = "http://www.w3.org/2001/04/xmlenc#sha512"
      SIGNED_PROPERTIES_TYPE = "http://uri.etsi.org/01903#SignedProperties"
      REFERENCE_ID_TYPE = "http://www.w3.org/2000/09/xmldsig#Object"

      NAMESPACES = {
        "ds" => "http://www.w3.org/2000/09/xmldsig#",
        "xades" => "http://uri.etsi.org/01903/v1.3.2#"
      }.freeze

      def initialize(doc, signing_ids)
        @doc = doc
        @signed_info_id = signing_ids[:signed_info_id]
        @signed_properties_id = signing_ids[:signed_properties_id]
        @certificate_id = signing_ids[:certificate_id]
        @reference_id = signing_ids[:reference_id]
      end

      def build
        signed_info = build_signed_info
        signed_info.add_child(build_canonicalization_method)
        signed_info.add_child(build_signature_method)

        # Signed properties reference
        signed_info.add_child(
          build_reference(type: SIGNED_PROPERTIES_TYPE,
                          uri: "##{@signed_properties_id}",
                          node_to_digest: find_node_by_id(@signed_properties_id))
        )

        # Certificate reference
        signed_info.add_child(
          build_reference(uri: "##{@certificate_id}",
                          node_to_digest: find_node_by_id(@certificate_id))
        )

        # Document reference - this needs to be the last reference
        # because it includes a transform that affects the whole document
        signed_info.add_child(
          build_reference(id: @reference_id,
                          type: REFERENCE_ID_TYPE,
                          include_transform: true,
                          node_to_digest: @doc.root)
        )

        signed_info
      end

      private

      def build_signed_info
        create_xml_element(@doc, "ds:SignedInfo", nil, { "Id" => @signed_info_id })
      end

      def build_canonicalization_method
        create_xml_node_with_algorithm(@doc, "ds:CanonicalizationMethod", C14N_METHOD_ALGORITHM)
      end

      def build_signature_method
        create_xml_node_with_algorithm(@doc, "ds:SignatureMethod", SIGNATURE_METHOD_ALGORITHM)
      end

      def build_reference(id: nil, type: nil, uri: nil, include_transform: false, node_to_digest: nil)
        attributes = {}
        attributes["Id"] = id if id
        attributes["Type"] = type if type
        attributes["URI"] = uri if uri

        ref = create_xml_element(@doc, "ds:Reference", nil, attributes)

        # Add transforms if needed
        ref.add_child(build_transforms) if include_transform

        # Add digest method
        ref.add_child(build_digest_method)

        # Add digest value
        ref.add_child(build_digest_value(node_to_digest))

        ref
      end

      def build_digest_method
        create_xml_node_with_algorithm(@doc, "ds:DigestMethod", DIGEST_METHOD_ALGORITHM)
      end

      def build_digest_value(node)
        create_xml_element(@doc, "ds:DigestValue", encoded_digest(node))
      end

      def build_transforms
        transforms = create_xml_element(@doc, "ds:Transforms")
        transform = create_xml_node_with_algorithm(@doc, "ds:Transform", TRANSFORM_ALGORITHM)
        transforms.add_child(transform)

        transforms
      end

      # Calculate the digest value for a node
      # @param node [Nokogiri::XML::Node, nil] The node to digest
      # @return [String] Base64-encoded digest value
      def encoded_digest(node)
        return "" unless node

        if node == @doc.root
          # Enveloped signature transform: remove Signature, then canonicalize whole document
          temp_doc = @doc.dup
          temp_doc.xpath("//ds:Signature", NAMESPACES).each(&:remove)
          canonicalized = temp_doc.canonicalize(Nokogiri::XML::XML_C14N_1_0)
        else
          # Canonicalize in-place as a subtree so ancestor namespace declarations
          # (xmlns:ds, xmlns:fe, xmlns:xades) are included — matching what a
          # standard XML-DSIG verifier will produce.
          canonicalized = node.canonicalize(Nokogiri::XML::XML_C14N_1_0)
        end

        # Calculate SHA-512 digest and encode in Base64
        digest = calculate_sha512_digest(canonicalized)
        base64_encode_raw(digest)
      end

      # Find a node by its ID attribute
      # @param id [String] The ID to look for
      # @return [Nokogiri::XML::Node, nil] The node with the matching ID
      def find_node_by_id(id)
        @doc.at_xpath("//*[@Id='#{id}']")
      end
    end
  end
end
