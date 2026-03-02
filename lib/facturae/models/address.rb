# frozen_string_literal: true

module Facturae
  # Represents an address.
  # @attr [String] address The address.
  # @attr [String] post_code The post code.
  # @attr [String] town The town.
  # @attr [String] province The province.
  # @attr [String] country_code The country code.
  class Address
    include Validatable

    ESP_CC = "ESP"
    COUNTRY_CODES = %w[AUT BEL BGR CYP CZE DEU DNK ESP EST
                       FIN FRA GRC HRV HUN IRL ITA LTU LUX
                       LVA MLT NLD POL PRT ROU SVK SVN SWE].freeze

    attr_accessor :address,
                  :post_code,
                  :town,
                  :province,
                  :country_code

    def initialize(address:, post_code:, province:, country_code:, town: nil)
      @address      = address
      @post_code    = post_code
      @town         = town
      @province     = province
      @country_code = country_code
    end

    private

    def validate
      super
      validate_required_fields
      validate_country_code
      add_error("town is required when country_code is ESP") if @country_code == ESP_CC && @town.nil?
    end

    def validate_required_fields
      add_error("address is required") unless @address
      add_error("post_code is required") unless @post_code
      add_error("province is required") unless @province
      add_error("country_code is required") unless @country_code
    end

    def validate_country_code
      return unless @country_code
      return if COUNTRY_CODES.include?(@country_code)

      add_error("country_code is not a valid EU country code")
    end
  end
end
