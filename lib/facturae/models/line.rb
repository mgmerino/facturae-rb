# frozen_string_literal: true

module Facturae
  # Represents a line in an invoice.
  # @attr [String] item_description The item description.
  # @attr [Float] quantity The quantity.
  # @attr [Float] unit_price_without_tax The unit price without tax.
  # @attr [Float] total_cost The total cost.
  # @attr [String] article_code The article code.
  # @attr [Array] discounts_and_rebates The discounts and rebates.
  # @attr [Array] charges The charges.
  # @attr [Float] gross_amount The gross amount.
  class Line
    # Default unit of measure code (units)
    UNIT_DEFAULT = "01"

    attr_accessor :item_description,
                  :quantity,
                  :unit_price_without_tax,
                  :total_cost,
                  :article_code,
                  :unit_of_measure,
                  :discounts_and_rebates,
                  :charges,
                  :gross_amount

    def initialize(item_description:, quantity:, unit_price_without_tax:, total_cost:,
                   article_code: nil, unit_of_measure: UNIT_DEFAULT)
      @item_description = item_description
      @quantity = quantity
      @unit_price_without_tax = unit_price_without_tax
      @total_cost = total_cost
      @article_code = article_code
      @unit_of_measure = unit_of_measure
      @discounts_and_rebates = []
      @charges = []
      @gross_amount = quantity * unit_price_without_tax
    end

    def add_discount(reason, amount)
      @discounts_and_rebates << { reason: reason, amount: amount }
    end

    def add_charge(reason, amount)
      @charges << { reason: reason, amount: amount }
    end

    def valid?
      return false unless @item_description.is_a?(String)
      return false unless @quantity.is_a?(Float)
      return false unless @unit_price_without_tax.is_a?(Float)
      return false unless @total_cost.is_a?(Float)
      return false unless @gross_amount.is_a?(Float)
      return false if @article_code && !@article_code.is_a?(String)
      return false unless @discounts_and_rebates.all? { |d| d[:reason].is_a?(String) && d[:amount].is_a?(Float) }
      return false unless @charges.all? { |c| c[:reason].is_a?(String) && c[:amount].is_a?(Float) }

      true
    end
  end
end
