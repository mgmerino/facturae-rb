# frozen_string_literal: true

module Facturae
  module Xades
    class ObjectInfo
      include Utils

      def initialize(doc, signature_id, sp_id, object_id, ref_doc_id, certificate, options)
        @doc = doc
        @signature_id = signature_id
        @sp_id = sp_id
        @object_id = object_id
        @ref_doc_id = ref_doc_id
        @certificate = certificate
        @options = options
      end

      def build
        object_node = @doc.create_element("ds:Object")
        object_node["Id"] = @object_id

        qualifying_props_node = @doc.create_element("xades:QualifyingProperties")
        qualifying_props_node["Target"] = "##{@signature_id}"

        signed_properties_node = @doc.create_element("xades:SignedProperties")
        signed_properties_node["Id"] = @sp_id

        # SignedSignatureProperties
        signed_properties_node.add_child(build_signed_signature_properties)

        # SignedDataObjectProperties
        signed_properties_node.add_child(build_signed_data_object_properties)

        qualifying_props_node.add_child(signed_properties_node)
        object_node.add_child(qualifying_props_node)
        object_node
      end

      private

      def build_signed_signature_properties
        signed_signature_props_node = @doc.create_element("xades:SignedSignatureProperties")
        # <xades:SigningTime>
        signed_signature_props_node.add_child(@doc.create_element("xades:SigningTime", Time.now.utc.iso8601))

        # <xades:SigningCertificate>
        signed_signature_props_node.add_child(build_signing_certificate_node)

        # <xades:SignaturePolicyIdentifier>
        signed_signature_props_node.add_child(build_signature_policy_identifier_node)

        # <xades:SignerRole>
        signed_signature_props_node.add_child(build_signer_role_node)

        signed_signature_props_node
      end

      def build_signing_certificate_node
        signing_certificate_node = @doc.create_element("xades:SigningCertificate")
        cert_node = @doc.create_element("xades:Cert")
        cert_node.add_child(build_cert_digest_node)
        cert_node.add_child(build_issuer_serial_node)

        signing_certificate_node.add_child(cert_node)

        signing_certificate_node
      end

      def build_cert_digest_node
        cert_digest_node = @doc.create_element("xades:CertDigest")
        digest_method_node = @doc.create_element("ds:DigestMethod")
        digest_method_node["Algorithm"] = "http://www.w3.org/2001/04/xmlenc#sha512"
        cert_digest_node.add_child(digest_method_node)

        digest_val = Base64.strict_encode64(OpenSSL::Digest::SHA512.digest(@certificate.to_der))
        digest_val_node = @doc.create_element("ds:DigestValue", digest_val)
        cert_digest_node.add_child(digest_val_node)

        cert_digest_node
      end

      def build_issuer_serial_node
        is_node = @doc.create_element("xades:IssuerSerial")
        xname   = @doc.create_element("ds:X509IssuerName", @certificate.issuer.to_s)
        xserial = @doc.create_element("ds:X509SerialNumber", @certificate.serial.to_s)
        is_node.add_child(xname)
        is_node.add_child(xserial)

        is_node
      end

      def build_signature_policy_identifier_node
        spi = @doc.create_element("xades:SignaturePolicyIdentifier")
        spid = @doc.create_element("xades:SignaturePolicyId")

        pid = @doc.create_element("xades:SigPolicyId")
        pid.add_child(@doc.create_element("xades:Identifier",
                                          "http://www.facturae.es/politica_de_firma_formato_facturae/politica_de_firma_formato_facturae_v3_1.pdf"))
        pid.add_child(@doc.create_element("xades:Description", "Política de Firma FacturaE v3.1"))
        spid.add_child(pid)

        sph = @doc.create_element("xades:SigPolicyHash")
        dm = @doc.create_element("ds:DigestMethod")
        dm["Algorithm"] = "http://www.w3.org/2000/09/xmldsig#sha1"
        sph.add_child(dm)
        dv = @doc.create_element("ds:DigestValue", "Ohixl6upD6av8N7pEvDABhEL6hM=")
        sph.add_child(dv)
        spid.add_child(sph)

        spi.add_child(spid)
        spi
      end

      def build_signer_role_node
        sr = @doc.create_element("xades:SignerRole")
        cr = @doc.create_element("xades:ClaimedRoles")
        cr.add_child(@doc.create_element("xades:ClaimedRole", "emisor")) # Ejemplo
        sr.add_child(cr)
        sr
      end

      def build_signed_data_object_properties
        sdp = @doc.create_element("xades:SignedDataObjectProperties")

        dof = @doc.create_element("xades:DataObjectFormat")
        dof["ObjectReference"] = "##{@ref_doc_id}"

        dof.add_child(@doc.create_element("xades:Description", "Factura electrónica"))
        oid = @doc.create_element("xades:ObjectIdentifier")
        ident = @doc.create_element("xades:Identifier", "urn:oid:1.2.840.10003.5.109.10")
        ident["Qualifier"] = "OIDAsURN"
        oid.add_child(ident)
        dof.add_child(oid)

        dof.add_child(@doc.create_element("xades:MimeType", "text/xml"))
        sdp.add_child(dof)
        sdp
      end
    end
  end
end
