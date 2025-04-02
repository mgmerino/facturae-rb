# frozen_string_literal: true

module Facturae
  # Represents an address.
  # @attr [String] address The address.
  # @attr [String] post_code The post code.
  # @attr [String] town The town.
  # @attr [String] province The province.
  # @attr [String] country_code The country code.
  class Address
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

    def valid?
      return false unless all_properties_present?
      return false unless COUNTRY_CODES.include?(@country_code)
      return false if @country_code == ESP_CC && @town.nil?

      true
    end

    private

    def all_properties_present?
      return true unless (@address && @post_code && @province && @country_code).nil?

      false
    end
  end
end
