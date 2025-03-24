# frozen_string_literal: true

module Facturae
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
