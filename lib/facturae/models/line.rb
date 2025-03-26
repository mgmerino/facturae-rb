# frozen_string_literal: true

module Facturae
  # Represents a line in an invoice.
  # @attr [String] item_description The item description.
  # @attr [Float] quantity The quantity.
  # @attr [Float] unit_price_without_tax The unit price without tax.
  # @attr [Float] gross_amount The gross amount.
  # @attr [Float] total_cost The total cost.
  class Line
    attr_accessor :item_description,
                  :quantity,
                  :unit_price_without_tax,
                  :gross_amount,
                  :total_cost

    def initialize(item_description:, quantity:, unit_price_without_tax:, gross_amount:, total_cost:)
      @item_description      = item_description
      @quantity              = quantity
      @unit_price_without_tax = unit_price_without_tax
      @gross_amount          = gross_amount
      @total_cost            = total_cost
    end

    def valid?
      return false unless @item_description.is_a?(String)
      return false unless @quantity.is_a?(Integer)
      return false unless @unit_price_without_tax.is_a?(Float)
      return false unless @gross_amount.is_a?(Float)
      return false unless @total_cost.is_a?(Float)

      true
    end
  end
end
