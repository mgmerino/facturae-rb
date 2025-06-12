# frozen_string_literal: true

module Facturae
  module Xades
    # This class is responsible for building the XAdES ObjectInfo element.
    class ObjectInfo
      include Utils

      ALGORITHM_SHA1 = "http://www.w3.org/2000/09/xmldsig#sha1"
      ALGORITHM_SHA512 = "http://www.w3.org/2001/04/xmlenc#sha512"
      OBJECT_DESCRIPTION = "Factura electrónica"
      OBJECT_IDENTIFIER = "urn:oid:1.2.840.10003.5.109.10"
      OBJECT_QUALIFIER = "OIDAsURN"
      OBJECT_MIME_TYPE = "application/xml"
      SIG_POLICY_URL = "http://www.facturae.es/politica_de_firma_formato_facturae/politica_de_firma_formato_facturae_v3_1.pdf"
      SIG_POLICY_DESCRIPTION = "Política de Firma FacturaE v3.1"
      SIG_POLICY_HASH_DIGEST = "Ohixl6upD6av8N7pEvDABhEL6hM="

      NAMESPACES = {
        "ds" => "http://www.w3.org/2000/09/xmldsig#",
        "xades" => "http://uri.etsi.org/01903/v1.3.2#"
      }.freeze

      # Initializes a new instance of ObjectInfo.
      #
      # @param doc [Nokogiri::XML::Document] The XML document to work with
      # @param certificate [OpenSSL::X509::Certificate] The X509 certificate used for signing
      # @param signing_ids [Hash] A hash containing the IDs used in the signature:
      #   - :signature_id [String] The ID of the signature element
      #   - :signed_properties_id [String] The ID of the signed properties element
      #   - :signature_object_id [String] The ID of the signature object element
      #   - :reference_id [String] The ID of the reference element
      def initialize(doc, certificate, signing_ids)
        @doc = doc
        @certificate = certificate

        @signature_id = signing_ids[:signature_id]
        @signed_properties_id = signing_ids[:signed_properties_id]
        @signature_object_id = signing_ids[:signature_object_id]
        @reference_id = signing_ids[:reference_id]
      end

      def build
        main_node = create_xml_element(@doc, "ds:Object", nil, { "Id" => @signature_object_id })

        qualifying_props_node = create_xml_element(@doc, "xades:QualifyingProperties", nil,
                                                   { "Target" => "##{@signature_id}" })
        signed_properties_node = create_xml_element(@doc, "xades:SignedProperties", nil,
                                                    { "Id" => @signed_properties_id })

        signed_properties_node.add_child(build_signed_signature_properties_node)
        signed_properties_node.add_child(build_signed_data_object_properties_node)

        qualifying_props_node.add_child(signed_properties_node)
        main_node.add_child(qualifying_props_node)

        main_node
      end

      private

      def build_signed_signature_properties_node
        main_node = create_xml_element(@doc, "xades:SignedSignatureProperties")
        main_node.add_child(create_xml_element(@doc, "xades:SigningTime", Time.now.utc.iso8601))
        main_node.add_child(build_signing_certificate_node)
        main_node.add_child(build_signature_policy_identifier_node)
        main_node.add_child(build_signer_role_node)

        main_node
      end

      def build_signing_certificate_node
        main_node = create_xml_element(@doc, "xades:SigningCertificate")
        cert_node = create_xml_element(@doc, "xades:Cert")
        cert_node.add_child(build_cert_digest_node)
        cert_node.add_child(build_issuer_serial_node)

        main_node.add_child(cert_node)

        main_node
      end

      def build_cert_digest_node
        main_node = create_xml_element(@doc, "xades:CertDigest")
        main_node.add_child(create_xml_node_with_algorithm(@doc, "ds:DigestMethod", ALGORITHM_SHA512))

        digest_val = base64_encode(@certificate.to_der)
        main_node.add_child(create_xml_element(@doc, "ds:DigestValue", digest_val))

        main_node
      end

      def build_issuer_serial_node
        main_node = create_xml_element(@doc, "xades:IssuerSerial")
        main_node.add_child(create_xml_element(@doc, "ds:X509IssuerName", @certificate.issuer.to_s))
        main_node.add_child(create_xml_element(@doc, "ds:X509SerialNumber", @certificate.serial.to_s))

        main_node
      end

      def build_signature_policy_identifier_node
        main_node = create_xml_element(@doc, "xades:SignaturePolicyIdentifier")
        policy_node = create_xml_element(@doc, "xades:SignaturePolicyId")

        policy_node.add_child(build_sig_policy_id)
        policy_node.add_child(build_sig_policy_hash)
        policy_node.add_child(build_sig_policy_qualifiers)
        main_node.add_child(policy_node)

        main_node
      end

      def build_sig_policy_id
        sig_policy_id = create_xml_element(@doc, "xades:SigPolicyId")
        identifier = create_xml_element(@doc, "xades:Identifier", OBJECT_IDENTIFIER)
        identifier.add_child(create_xml_element(@doc, "xades:Description", OBJECT_DESCRIPTION))
        sig_policy_id.add_child(identifier)
        sig_policy_id.add_child(create_xml_element(@doc, "xades:Description", SIG_POLICY_DESCRIPTION))
        sig_policy_id
      end

      def build_sig_policy_hash
        sig_policy_hash = create_xml_element(@doc, "xades:SigPolicyHash")
        sig_policy_hash.add_child(create_xml_node_with_algorithm(@doc, "ds:DigestMethod", ALGORITHM_SHA1))
        sig_policy_hash.add_child(create_xml_element(@doc, "ds:DigestValue", SIG_POLICY_HASH_DIGEST))
        sig_policy_hash
      end

      def build_sig_policy_qualifiers
        sig_policy_qualifiers = create_xml_element(@doc, "xades:SigPolicyQualifiers")
        sig_policy_qualifier = create_xml_element(@doc, "xades:SigPolicyQualifier")
        sig_policy_qualifier.add_child(create_xml_element(@doc, "xades:SPURI", SIG_POLICY_URL))
        sig_policy_qualifiers.add_child(sig_policy_qualifier)
        sig_policy_qualifiers
      end

      def build_signer_role_node
        main_node = create_xml_element(@doc, "xades:SignerRole")
        claimed_roles = create_xml_element(@doc, "xades:ClaimedRoles")
        claimed_roles.add_child(create_xml_element(@doc, "xades:ClaimedRole", "supplier"))
        main_node.add_child(claimed_roles)

        main_node
      end

      def build_signed_data_object_properties_node
        main_node = create_xml_element(@doc, "xades:SignedDataObjectProperties")
        data_object_format = create_xml_element(@doc, "xades:DataObjectFormat", nil,
                                                { "ObjectReference" => "##{@reference_id}" })

        description = create_xml_element(@doc, "xades:Description", OBJECT_DESCRIPTION)
        object_identifier = create_xml_element(@doc, "xades:ObjectIdentifier")
        identifier = create_xml_element(@doc, "xades:Identifier", OBJECT_IDENTIFIER,
                                        { "Qualifier" => OBJECT_QUALIFIER })
        mime_type = create_xml_element(@doc, "xades:MimeType", OBJECT_MIME_TYPE)

        object_identifier.add_child(identifier)
        data_object_format.add_child(description)
        data_object_format.add_child(object_identifier)
        data_object_format.add_child(mime_type)
        main_node.add_child(data_object_format)

        main_node
      end
    end
  end
end
