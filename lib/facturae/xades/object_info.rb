# frozen_string_literal: true

module Facturae
  module Xades
    # This class is responsible for building the XAdES ObjectInfo element.
    class ObjectInfo
      ALGORITHM_SHA1 = "http://www.w3.org/2000/09/xmldsig#sha1"
      ALGORITHM_SHA512 = "http://www.w3.org/2001/04/xmlenc#sha512"
      OBJECT_DESCRIPTION = "Factura electrónica"
      OBJECT_IDENTIFIER = "urn:oid:1.2.840.10003.5.109.10"
      OBJECT_QUALIFIER = "OIDAsURN"
      OBJECT_MIME_TYPE = "application/xml"
      SIG_POLICY_URL = "http://www.facturae.es/politica_de_firma_formato_facturae/politica_de_firma_formato_facturae_v3_1.pdf"
      SIG_POLICY_DESCRIPTION = "Política de Firma FacturaE v3.1"
      SIG_POLICY_HASH_DIGEST = "Ohixl6upD6av8N7pEvDABhEL6hM="

      def initialize(doc, certificate, signing_ids)
        @doc = doc
        @certificate = certificate

        @signature_id = signing_ids[:signature_id]
        @signed_properties_id = signing_ids[:signed_properties_id]
        @signature_object_id = signing_ids[:signature_object_id]
        @reference_id = signing_ids[:reference_id]
      end

      def build
        main_node = @doc.create_element("ds:Object")

        main_node["Id"] = @signature_object_id

        qualifying_props_node = @doc.create_element("xades:QualifyingProperties")
        qualifying_props_node["Target"] = "##{@signature_id}"

        signed_properties_node = @doc.create_element("xades:SignedProperties")
        signed_properties_node["Id"] = @signed_properties_id

        signed_properties_node.add_child(build_signed_signature_properties_node)
        signed_properties_node.add_child(build_signed_data_object_properties_node)

        qualifying_props_node.add_child(signed_properties_node)
        main_node.add_child(qualifying_props_node)

        main_node
      end

      private

      def build_signed_signature_properties_node
        main_node = @doc.create_element("xades:SignedSignatureProperties")
        main_node.add_child(@doc.create_element("xades:SigningTime", Time.now.utc.iso8601))
        # <xades:SigningCertificate>
        main_node.add_child(build_signing_certificate_node)
        # <xades:SignaturePolicyIdentifier>
        main_node.add_child(build_signature_policy_identifier_node)
        # <xades:SignerRole>
        main_node.add_child(build_signer_role_node)

        main_node
      end

      def build_signing_certificate_node
        main_node = @doc.create_element("xades:SigningCertificate")
        cert_node = @doc.create_element("xades:Cert")
        cert_node.add_child(build_cert_digest_node)
        cert_node.add_child(build_issuer_serial_node)

        main_node.add_child(cert_node)

        main_node
      end

      def build_cert_digest_node
        main_node = @doc.create_element("xades:CertDigest")
        digest_method_node = @doc.create_element("ds:DigestMethod")
        digest_method_node["Algorithm"] = ALGORITHM_SHA512
        main_node.add_child(digest_method_node)

        digest_val = Base64.strict_encode64(OpenSSL::Digest::SHA512.digest(@certificate.to_der))
        digest_val_node = @doc.create_element("ds:DigestValue", digest_val)
        main_node.add_child(digest_val_node)

        main_node
      end

      def build_issuer_serial_node
        main_node = @doc.create_element("xades:IssuerSerial")
        xname   = @doc.create_element("ds:X509IssuerName", @certificate.issuer.to_s)
        xserial = @doc.create_element("ds:X509SerialNumber", @certificate.serial.to_s)
        main_node.add_child(xname)
        main_node.add_child(xserial)

        main_node
      end

      def build_signature_policy_identifier_node
        main_node = @doc.create_element("xades:SignaturePolicyIdentifier")

        signature_policy_id_node = @doc.create_element("xades:SignaturePolicyId")
        signature_policy_id_node.add_child(build_sig_policy_id_node)
        signature_policy_id_node.add_child(build_sig_policy_hash_node)

        main_node.add_child(signature_policy_id_node)

        main_node
      end

      def build_sig_policy_id_node
        main_node = @doc.create_element("xades:SigPolicyId")
        main_node.add_child(@doc.create_element("xades:Identifier", SIG_POLICY_URL))
        main_node.add_child(@doc.create_element("xades:Description", SIG_POLICY_DESCRIPTION))

        main_node
      end

      def build_sig_policy_hash_node
        main_node = @doc.create_element("xades:SigPolicyHash")

        digest_method_node = @doc.create_element("ds:DigestMethod")
        digest_method_node["Algorithm"] = ALGORITHM_SHA1
        main_node.add_child(digest_method_node)

        digest_value_node = @doc.create_element("ds:DigestValue", SIG_POLICY_HASH_DIGEST)
        main_node.add_child(digest_value_node)

        main_node
      end

      def build_signer_role_node
        main_node = @doc.create_element("xades:SignerRole")
        claimed_roles_node = @doc.create_element("xades:ClaimedRoles")
        claimed_roles_node.add_child(@doc.create_element("xades:ClaimedRole", "emisor"))
        main_node.add_child(claimed_roles_node)

        main_node
      end

      def build_signed_data_object_properties_node
        main_node = @doc.create_element("xades:SignedDataObjectProperties")
        main_node.add_child(build_data_object_format_node)

        main_node
      end

      def build_data_object_format_node
        main_node = @doc.create_element("xades:DataObjectFormat")
        main_node["ObjectReference"] = "##{@ref_id}"

        main_node.add_child(@doc.create_element("xades:Description", OBJECT_DESCRIPTION))
        object_id_node = @doc.create_element("xades:ObjectIdentifier")
        identifier_node = @doc.create_element("xades:Identifier", OBJECT_IDENTIFIER)
        identifier_node["Qualifier"] = OBJECT_QUALIFIER
        object_id_node.add_child(identifier_node)
        main_node.add_child(object_id_node)

        main_node.add_child(@doc.create_element("xades:MimeType", OBJECT_MIME_TYPE))

        main_node
      end
    end
  end
end
