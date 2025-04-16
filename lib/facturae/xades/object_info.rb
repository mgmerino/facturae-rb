# frozen_string_literal: true

module Facturae
  module Xades
    # TODO: review static values
    # This class is responsible for building the XAdES ObjectInfo element.
    class ObjectInfo
      include Utils

      DIGEST_METHOD_ALGORITHM = "http://www.w3.org/2001/04/xmlenc#sha512"

      def initialize(doc, ids, certificate, options)
        @doc = doc
        @signature_id = ids[:signature_id]
        @sp_id = ids[:sp_id]
        @object_id = ids[:object_id]
        @ref_doc_id = ids[:ref_doc_id]
        @certificate = certificate
        @options = options
      end

      def build
        main_node = @doc.create_element("ds:Object")
        main_node["Id"] = @object_id

        qualifying_props_node = @doc.create_element("xades:QualifyingProperties")
        qualifying_props_node["Target"] = "##{@signature_id}"

        signed_properties_node = @doc.create_element("xades:SignedProperties")
        signed_properties_node["Id"] = @sp_id

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
        digest_method_node["Algorithm"] = "http://www.w3.org/2001/04/xmlenc#sha512"
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
        main_node.add_child(@doc.create_element("xades:Identifier",
                                                "http://www.facturae.es/politica_de_firma_formato_facturae/politica_de_firma_formato_facturae_v3_1.pdf"))
        main_node.add_child(@doc.create_element("xades:Description", "Política de Firma FacturaE v3.1"))

        main_node
      end

      def build_sig_policy_hash_node
        main_node = @doc.create_element("xades:SigPolicyHash")

        digest_method_node = @doc.create_element("ds:DigestMethod")
        digest_method_node["Algorithm"] = "http://www.w3.org/2000/09/xmldsig#sha1"
        main_node.add_child(digest_method_node)

        digest_value_node = @doc.create_element("ds:DigestValue", "foo")
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
        main_node["ObjectReference"] = "##{@ref_doc_id}"

        main_node.add_child(@doc.create_element("xades:Description", "Factura electrónica"))
        object_id_node = @doc.create_element("xades:ObjectIdentifier")
        identifier_node = @doc.create_element("xades:Identifier", "urn:oid:1.2.840.10003.5.109.10")
        identifier_node["Qualifier"] = "OIDAsURN"
        object_id_node.add_child(identifier_node)
        main_node.add_child(object_id_node)

        main_node.add_child(@doc.create_element("xades:MimeType", "text/xml"))

        main_node
      end
    end
  end
end
