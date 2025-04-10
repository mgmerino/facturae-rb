# frozen_string_literal: true

module Facturae
  module Xades
    # Handles the signing of XML documents using XAdES.
    class XadesSigner
      include Utils

      XADES_NAMESPACE = "http://uri.etsi.org/01903/v1.3.2#"

      attr_reader :xml_doc

      def initialize(xml_doc, private_key, certificate, options = {})
        @xml_doc = xml_doc
        @private_key = private_key
        @certificate = certificate
        @options = options

        @signature_id  = "Signature#{rand_id}"
        # @sp_id         = "#{@signature_id}-SignedProperties#{rand_id}"
        # @cert_id       = "Certificate#{rand_id}"
        # @object_id     = "#{@signature_id}-Object#{rand_id}"
        # @ref_doc_id    = "Reference-ID-#{rand_id}"
      end

      def sign
        signature_node = build_signature_node
        @xml_doc.root.add_child(signature_node)
      end

      private

      def build_signature_node
        signature = @xml_doc.create_element("ds:Signature")
        signature["Id"] = @signature_id
        signature["xmlns:xades"] = XADES_NAMESPACE
        signature
      end
    end
  end
end
