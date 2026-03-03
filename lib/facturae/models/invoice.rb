# frozen_string_literal: true

module Facturae
  # Represents an invoice.
  # @attr [Hash] invoice_header The invoice header.
  # @attr [Hash] issue_data The issue data.
  # @attr [Hash] totals The totals.
  # @attr [Array<Facturae::Tax>] taxes_output The taxes output.
  # @attr [Array<Facturae::Tax>] taxes_withheld The taxes withheld.
  # @attr [Array<Facturae::InvoiceLine>] invoice_line The invoice lines.
  class Invoice
    include Validatable

    INVOICE_HEADER_KEYS = %i[invoice_number invoice_series_code invoice_document_type invoice_class].freeze
    ISSUE_DATA_KEYS = %i[issue_date language_name invoice_currency_code tax_currency_code].freeze
    TOTALS_KEYS = %i[total_gross_amount total_gross_amount_before_taxes total_tax_outputs total_taxes_withheld
                     invoice_total total_outstanding_amount total_executable_amount].freeze

    attr_accessor :invoice_header,
                  :issue_data,
                  :totals,
                  :taxes_output,
                  :taxes_withheld,
                  :invoice_lines

    # rubocop:disable Metrics/ParameterLists
    def initialize(invoice_header: nil,
                   issue_data: nil,
                   totals: nil,
                   taxes_output: nil,
                   taxes_withheld: nil,
                   invoice_lines: nil)
      @invoice_header = invoice_header || {
        invoice_number: "unset",
        invoice_series_code: "unset",
        invoice_document_type: "unset",
        invoice_class: "unset"
      }
      @issue_data = issue_data || {
        issue_date: Date.today,
        invoice_currency_code: "unset",
        language_name: "unset"
      }
      @totals = totals || {
        total_gross_amount: 0.0,
        total_gross_amount_before_taxes: 0.0,
        total_tax_outputs: 0.0,
        total_taxes_withheld: 0.0,
        invoice_total: 0.0,
        total_outstanding_amount: 0.0,
        total_executable_amount: 0.0
      }
      @taxes_output = taxes_output || []
      @taxes_withheld = taxes_withheld || []
      @invoice_lines = invoice_lines || []
    end
    # rubocop:enable Metrics/ParameterLists

    def add_invoice_line(invoice_line)
      @invoice_lines << invoice_line
    end

    def add_tax_output(tax)
      @taxes_output << tax
    end

    def add_tax_withheld(tax)
      @taxes_withheld << tax
    end

    private

    def validate
      super
      validate_hash_keys("invoice_header", @invoice_header, INVOICE_HEADER_KEYS)
      validate_hash_keys("issue_data", @issue_data, ISSUE_DATA_KEYS)
      validate_hash_keys("totals", @totals, TOTALS_KEYS)
      validate_children("taxes_output", @taxes_output)
      validate_children("taxes_withheld", @taxes_withheld)
      validate_children("invoice_lines", @invoice_lines)
      validate_totals_arithmetic
    end

    def validate_hash_keys(name, hash, allowed_keys)
      invalid_keys = hash.keys - allowed_keys
      invalid_keys.each do |key|
        add_error("#{name} contains unknown key: #{key}")
      end
    end

    def validate_totals_arithmetic
      validate_total_gross_amount
      validate_invoice_total
    end

    def validate_total_gross_amount
      return if @invoice_lines.empty?

      expected = @invoice_lines.sum { |line| line.gross_amount.is_a?(Float) ? line.gross_amount : 0.0 }.round(2)
      return if @totals[:total_gross_amount].is_a?(Float) && @totals[:total_gross_amount].round(2) == expected

      add_error("total_gross_amount must equal sum of line gross_amounts")
    end

    def validate_invoice_total
      t = @totals
      return unless [t[:total_gross_amount_before_taxes], t[:total_tax_outputs],
                     t[:total_taxes_withheld], t[:invoice_total]].all? { |v| v.is_a?(Float) }

      expected = (t[:total_gross_amount_before_taxes] + t[:total_tax_outputs] - t[:total_taxes_withheld]).round(2)
      return if t[:invoice_total].round(2) == expected

      add_error("invoice_total must equal gross_before_taxes + tax_outputs - taxes_withheld")
    end
  end
end
