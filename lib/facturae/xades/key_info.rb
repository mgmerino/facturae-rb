# frozen_string_literal: true

module Facturae
  module Xades
    # Builds the KeyInfo element in XML signatures.
    class KeyInfo
      include Utils

      def initialize(doc, certificate, options = {})
        @doc = doc
        @certificate = certificate
        @options = options
      end

      def build
        key_info = @doc.create_element("ds:KeyInfo")
        key_info["Id"] = "Certificate#{rand_id}"

        key_info.add_child(build_x509_data)
        key_info.add_child(build_key_value)

        key_info
      end

      private

      def build_x509_data
        x509_data = @doc.create_element("ds:X509Data")
        cert_node = @doc.create_element("ds:X509Certificate", Base64.strict_encode64(@certificate.to_der))
        x509_data.add_child(cert_node)

        x509_data
      end

      def build_key_value
        key_value = @doc.create_element("ds:KeyValue")
        rsa_key = @doc.create_element("ds:RSAKeyValue")
        modulus, exponent = calculate_modulus_and_exponent

        key_value.add_child(rsa_key)
        rsa_key.add_child(@doc.create_element("ds:Modulus", modulus))
        rsa_key.add_child(@doc.create_element("ds:Exponent", exponent))

        key_value
      end

      def calculate_modulus_and_exponent
        modulus = Base64.strict_encode64(@certificate.public_key.n.to_s(2))
        exponent = Base64.strict_encode64(@certificate.public_key.e.to_s(2))

        [modulus, exponent]
      end
    end
  end
end
