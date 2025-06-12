# frozen_string_literal: true

require "securerandom"
require "openssl"
require "base64"

module Facturae
  module Xades
    # Utility methods for generating random IDs and encoding data in Base64.
    module Utils
      def rand_id
        # SecureRandom.alphanumeric(6)
        SecureRandom.uuid
      end

      def base64_encode(data)
        digest_bytes = OpenSSL::Digest::SHA512.digest(data)
        Base64.strict_encode64(digest_bytes)
      end

      def base64_encode_raw(data)
        Base64.strict_encode64(data)
      end

      def calculate_sha512_digest(data)
        OpenSSL::Digest::SHA512.digest(data)
      end

      def create_xml_element(doc, name, content = nil, attributes = {})
        element = doc.create_element(name, content)
        attributes.each { |key, value| element[key] = value }
        element
      end

      def create_xml_node_with_algorithm(doc, name, algorithm)
        create_xml_element(doc, name, nil, { "Algorithm" => algorithm })
      end
    end
  end
end
