# frozen_string_literal: true

module Facturae
  module Xades
    # Handles the building of the SignedInfo element for XAdES signatures.
    class SignedInfo
      include Utils

      C14N_METHOD_ALGORITHM = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
      SIGNATURE_METHOD_ALGORITHM = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
      TRANSFORM_ALGORITHM = "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
      DIGEST_METHOD_ALGORITHM = "http://www.w3.org/2001/04/xmlenc#sha512"
      SIGNED_PROPERTIES_TYPE = "http://uri.etsi.org/01903#SignedProperties"
      REFERENCE_ID_TYPE = "http://www.w3.org/2000/09/xmldsig#Object"

      def initialize(doc, signing_ids = {})
        @doc = doc
        @signed_info_id = signing_ids[:signed_info_id]
        @signature_signed_properties_id = signing_ids[:signature_signed_properties_id]
        @signed_properties_id = "SignedPropertiesID#{rand_id}"
        @cert_uri = "#Certificate#{rand_id}"
        @ref_id = "Reference-ID-#{rand_id}"
      end

      def build
        signed_info = build_signed_info
        signed_info.add_child(build_canonicalization_method)
        signed_info.add_child(build_signature_method)

        # Signed properties reference
        signed_info.add_child(
          build_reference(id: @signature_signed_properties_id,
                          type: SIGNED_PROPERTIES_TYPE,
                          uri: @signature_signed_properties_id)
        )

        # Certificate reference
        signed_info.add_child(
          build_reference(uri: @cert_uri)
        )

        # Document reference
        signed_info.add_child(
          build_reference(id: @ref_id,
                          type: REFERENCE_ID_TYPE,
                          include_transform: true)
        )

        signed_info
      end

      private

      def build_signed_info
        signed_info = @doc.create_element("ds:SignedInfo")
        signed_info["Id"] = @signed_info_id

        signed_info
      end

      def build_canonicalization_method
        canonicalization_method = @doc.create_element("ds:CanonicalizationMethod")
        canonicalization_method["Algorithm"] = C14N_METHOD_ALGORITHM

        canonicalization_method
      end

      def build_signature_method
        signature_method = @doc.create_element("ds:SignatureMethod")
        signature_method["Algorithm"] = SIGNATURE_METHOD_ALGORITHM

        signature_method
      end

      def build_reference(id: nil, type: nil, uri: nil, include_transform: false, node_to_digest: nil)
        ref = @doc.create_element("ds:Reference")
        ref["Id"] = id if id
        ref["Type"] = type if type
        ref["URI"] = uri if uri

        ref.add_child(build_digest_method)
        ref.add_child(build_digest_value(node_to_digest))

        ref.add_child(build_transforms) if include_transform

        ref
      end

      def build_digest_method
        digest_method = @doc.create_element("ds:DigestMethod")
        digest_method["Algorithm"] = DIGEST_METHOD_ALGORITHM

        digest_method
      end

      def build_digest_value(value)
        @doc.create_element("ds:DigestValue", encoded_digest(value))
      end

      def build_transforms
        transforms = @doc.create_element("ds:Transforms")
        transform = @doc.create_element("ds:Transform")
        transform["Algorithm"] = TRANSFORM_ALGORITHM
        transforms.add_child(transform)

        transforms
      end
    end
  end
end
