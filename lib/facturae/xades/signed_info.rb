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

      def initialize(doc, options)
        @doc = doc
        @options = options
        @signature_id = "Signature-SignedInfo#{rand_id}"
        @signed_properties_id = "SignedPropertiesID#{rand_id}"
        @signed_properties_uri = "#Signature#{rand_id}-SignedProperties#{rand_id}"
        @cert_uri = "#Certificate#{rand_id}"
        @ref_id = "Reference-ID-#{rand_id}"
      end

      def build
        signed_info = build_signed_info
        signed_info.add_child(build_canonicalization_method)
        signed_info.add_child(build_signature_method)

        # Signed properties reference
        signed_info.add_child(
          build_reference(id: @signed_properties_id,
                          type: SIGNED_PROPERTIES_TYPE,
                          uri: @signed_properties_uri,
                          algorithm: DIGEST_METHOD_ALGORITHM)
        )

        # Certificate reference
        signed_info.add_child(
          build_reference(uri: @cert_uri,
                          algorithm: DIGEST_METHOD_ALGORITHM)
        )

        # Document reference
        signed_info.add_child(
          build_reference(id: @ref_id,
                          type: REFERENCE_ID_TYPE,
                          algorithm: DIGEST_METHOD_ALGORITHM,
                          transform: TRANSFORM_ALGORITHM)
        )

        signed_info
      end

      private

      def build_signed_info
        signed_info = @doc.create_element("ds:SignedInfo")
        signed_info["Id"] = @signature_id

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

      def build_reference(algorithm:, id: nil, type: nil, uri: nil, transform: nil)
        ref = @doc.create_element("ds:Reference")
        ref["Id"] = id if id
        ref["Type"] = type if type
        ref["URI"] = uri if uri

        digest_method = @doc.create_element("ds:DigestMethod")
        digest_method["Algorithm"] = algorithm
        ref.add_child(digest_method)

        digest_value = @doc.create_element("ds:DigestValue", "")
        ref.add_child(digest_value)

        if transform
          transforms_node = @doc.create_element("ds:Transforms")
          t_node = @doc.create_element("ds:Transform")
          t_node["Algorithm"] = transform
          transforms_node.add_child(t_node)
          ref.add_child(transforms_node)
        end

        ref
      end
    end
  end
end
