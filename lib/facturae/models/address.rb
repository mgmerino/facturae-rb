# frozen_string_literal: true

module Facturae
  # Represents an address.
  # @attr [String] address The address.
  # @attr [String] post_code The post code.
  # @attr [String] town The town.
  # @attr [String] province The province.
  # @attr [String] country_code The country code.
  class Address
    attr_accessor :address,
                  :post_code,
                  :town,
                  :province,
                  :country_code

    def initialize(address:, post_code:, province:, town: nil, country_code: "ESP")
      @address      = address
      @post_code    = post_code
      @town         = town
      @province     = province
      @country_code = country_code
    end
  end
end
