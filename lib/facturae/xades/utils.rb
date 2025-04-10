# frozen_string_literal: true

require "securerandom"
require "openssl"
require "base64"

module Facturae
  module Xades
    # Utility methods for generating random IDs and encoding data in Base64.
    module Utils
      def rand_id
        SecureRandom.uuid
      end

      def base64_encode(data)
        digest_bytes = OpenSSL::Digest::SHA512.digest(data)
        Base64.strict_encode64(digest_bytes)
      end
    end
  end
end
