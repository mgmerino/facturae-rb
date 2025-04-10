# frozen_string_literal: true

module Facturae
  module Xades
    RSpec.describe Utils do
      let(:dummy_class) { Class.new { extend Utils } }

      describe ".rand_id" do
        it "returns a random UUID" do
          expect(dummy_class.rand_id).to match(
            /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/
          )
        end
      end

      describe ".base64_encode" do
        it "encodes data to Base64" do
          data = "These are not the droids you are looking for"
          encoded_data = dummy_class.base64_encode(data)
          expect(encoded_data).to eq(Base64.strict_encode64(OpenSSL::Digest::SHA512.digest(data)))
        end
      end
    end
  end
end
