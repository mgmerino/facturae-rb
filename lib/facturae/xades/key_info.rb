# frozen_string_literal: true

module Facturae
  module Xades
    # Builds the KeyInfo element in XML signatures.
    class KeyInfo
      include Utils

      NAMESPACES = {
        "ds" => "http://www.w3.org/2000/09/xmldsig#",
        "xades" => "http://uri.etsi.org/01903/v1.3.2#"
      }.freeze

      def initialize(doc, certificate, signing_ids)
        @doc = doc
        @certificate = certificate
        @certificate_id = signing_ids[:certificate_id] || "Certificate#{rand_id}"
      end

      def build
        key_info = create_xml_element(@doc, "ds:KeyInfo", nil, { "Id" => @certificate_id })
        key_info.add_child(build_x509_data)
        key_info.add_child(build_key_value)

        key_info
      end

      private

      def build_x509_data
        x509_data = create_xml_element(@doc, "ds:X509Data")
        cert_node = create_xml_element(@doc, "ds:X509Certificate", base64_encode_raw(@certificate.to_der))
        x509_data.add_child(cert_node)

        x509_data
      end

      def build_key_value
        key_value = create_xml_element(@doc, "ds:KeyValue")
        rsa_key = create_xml_element(@doc, "ds:RSAKeyValue")
        modulus, exponent = calculate_modulus_and_exponent

        key_value.add_child(rsa_key)
        rsa_key.add_child(create_xml_element(@doc, "ds:Modulus", modulus))
        rsa_key.add_child(create_xml_element(@doc, "ds:Exponent", exponent))

        key_value
      end

      def calculate_modulus_and_exponent
        modulus = base64_encode_raw(@certificate.public_key.n.to_s(2))
        exponent = base64_encode_raw(@certificate.public_key.e.to_s(2))

        [modulus, exponent]
      end
    end
  end
end
