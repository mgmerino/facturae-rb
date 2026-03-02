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
    include Validatable

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
                  :gross_amount,
                  :taxes_output

    def initialize(item_description:, quantity:, unit_price_without_tax:, total_cost:, **options)
      @item_description = item_description
      @quantity = quantity
      @unit_price_without_tax = unit_price_without_tax
      @total_cost = total_cost
      @article_code = options.fetch(:article_code, nil)
      @unit_of_measure = options.fetch(:unit_of_measure, UNIT_DEFAULT)
      @taxes_output = options.fetch(:taxes_output, [])
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

    private

    def validate
      super
      add_error("item_description must be a String") unless @item_description.is_a?(String)
      add_error("quantity must be a Float") unless @quantity.is_a?(Float)
      add_error("unit_price_without_tax must be a Float") unless @unit_price_without_tax.is_a?(Float)
      add_error("total_cost must be a Float") unless @total_cost.is_a?(Float)
      add_error("gross_amount must be a Float") unless @gross_amount.is_a?(Float)
      add_error("article_code must be a String") if @article_code && !@article_code.is_a?(String)
      validate_discounts_and_rebates
      validate_charges
    end

    def validate_discounts_and_rebates
      @discounts_and_rebates.each_with_index do |discount, i|
        add_error("discounts_and_rebates[#{i}].reason must be a String") unless discount[:reason].is_a?(String)
        add_error("discounts_and_rebates[#{i}].amount must be a Float") unless discount[:amount].is_a?(Float)
      end
    end

    def validate_charges
      @charges.each_with_index do |charge, i|
        add_error("charges[#{i}].reason must be a String") unless charge[:reason].is_a?(String)
        add_error("charges[#{i}].amount must be a Float") unless charge[:amount].is_a?(Float)
      end
    end
  end
end
