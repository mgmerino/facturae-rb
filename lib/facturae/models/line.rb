# frozen_string_literal: true

module Facturae
  # Represents a line in an invoice.
  # @attr [String] item_description The item description.
  # @attr [Float] quantity The quantity.
  # @attr [Float] unit_price_without_tax The unit price without tax.
  # @attr [Float] gross_amount The gross amount.
  # @attr [Float] total_cost The total cost.
  # @attr [String] unit_of_measure The unit of measure.
  #                Available units are defined in the UNITS_OF_MEASURE constant.
  class Line
    UNIT_DEFAULT = "01"
    UNIT_HOURS = "02"
    UNIT_KILOGRAMS = "03"
    UNIT_LITERS = "04"
    UNIT_OTHER = "05"
    UNIT_BOXES = "06"
    UNIT_TRAYS = "07"
    UNIT_BARRELS = "08"
    UNIT_JERRICANS = "09"
    UNIT_BAGS = "10"
    UNIT_CARBOYS = "11"
    UNIT_BOTTLES = "12"
    UNIT_CANISTERS = "13"
    UNIT_TETRABRIKS = "14"
    UNIT_CENTILITERS = "15"
    UNIT_CENTIMITERS = "16"
    UNIT_BINS = "17"
    UNIT_DOZENS = "18"
    UNIT_CASES = "19"
    UNIT_DEMIJOHNS = "20"
    UNIT_GRAMS = "21"
    UNIT_KILOMETERS = "22"
    UNIT_CANS = "23"
    UNIT_BUNCHES = "24"
    UNIT_METERS = "25"
    UNIT_MILIMETERS = "26"
    UNIT_6PACKS = "27"
    UNIT_PACKAGES = "28"
    UNIT_PORTIONS = "29"
    UNIT_ROLLS = "30"
    UNIT_ENVELOPES = "31"
    UNIT_TUBS = "32"
    UNIT_CUBICMETERS = "33"
    UNIT_SECONDS = "34"
    UNIT_WATTS = "35"
    UNIT_KWH = "36"

    UNITS_OF_MEASURE = [UNIT_DEFAULT, UNIT_HOURS, UNIT_KILOGRAMS, UNIT_LITERS,
                        UNIT_OTHER, UNIT_BOXES, UNIT_TRAYS, UNIT_BARRELS,
                        UNIT_JERRICANS, UNIT_BAGS, UNIT_CARBOYS, UNIT_BOTTLES,
                        UNIT_CANISTERS, UNIT_TETRABRIKS, UNIT_CENTILITERS,
                        UNIT_CENTIMITERS, UNIT_BINS, UNIT_DOZENS, UNIT_CASES,
                        UNIT_DEMIJOHNS, UNIT_GRAMS, UNIT_KILOMETERS, UNIT_CANS,
                        UNIT_BUNCHES, UNIT_METERS, UNIT_MILIMETERS, UNIT_6PACKS,
                        UNIT_PACKAGES, UNIT_PORTIONS, UNIT_ROLLS, UNIT_ENVELOPES,
                        UNIT_TUBS, UNIT_CUBICMETERS, UNIT_SECONDS, UNIT_WATTS,
                        UNIT_KWH].freeze

    attr_accessor :item_description,
                  :quantity,
                  :unit_price_without_tax,
                  :unit_of_measure,
                  :gross_amount,
                  :total_cost,
                  :article_code

    # rubocop:disable Metrics/ParameterLists
    def initialize(item_description:,
                   quantity:,
                   unit_price_without_tax:,
                   gross_amount:,
                   total_cost:,
                   unit_of_measure:)
      @item_description       = item_description
      @quantity               = quantity
      @unit_price_without_tax = unit_price_without_tax
      @gross_amount           = gross_amount
      @total_cost             = total_cost
      @unit_of_measure        = unit_of_measure
    end
    # rubocop:enable Metrics/ParameterLists

    def valid?
      return false unless @item_description.is_a?(String)
      return false unless @quantity.is_a?(Integer)
      return false unless @unit_price_without_tax.is_a?(Float)
      return false unless @gross_amount.is_a?(Float)
      return false unless @total_cost.is_a?(Float)
      return false unless unit_of_measure_valid?

      true
    end

    private

    def unit_of_measure_valid?
      return false unless UNITS_OF_MEASURE.include?(@unit_of_measure)
      return false unless @unit_of_measure.is_a?(String)

      true
    end
  end
end
