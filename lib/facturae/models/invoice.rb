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
    attr_accessor :invoice_header,
                  :issue_data,
                  :totals,
                  :taxes_output,
                  :taxes_withheld,
                  :invoice_lines

    def initialize
      @invoice_header = {
        invoice_number: nil,
        invoice_series_code: nil,
        invoice_document_type: "unset",
        invoice_class: "unset"
      }
      @issue_data = {
        issue_date: nil,
        language_name: "unset",
        invoice_currency_code: "unset"
      }
      @totals = {
        total_gross_amount: 0.0,
        total_tax_outputs: 0.0,
        total_taxes_withheld: 0.0,
        invoice_total: 0.0,
        payment_on_account: 0.0,
        payment_due: 0.0,
        total_outstanding_amount: 0.0,
        total_executable_amount: 0.0
      }
      @taxes_output = []
      @taxes_withheld = []
      @invoice_lines = []
    end

    def add_invoice_line(invoice_line)
      @invoice_lines << invoice_line
    end

    def add_tax_output(tax)
      @taxes_output << tax
    end

    def add_tax_withheld(tax)
      @taxes_withheld << tax
    end

    def valid?
      return false unless invoice_header_valid?
      return false unless issue_data_valid?
      return false unless totals_valid?
      return false unless taxes_output_valid?
      return false unless taxes_withheld_valid?
      return false unless invoice_line_valid?

      true
    end

    private

    def invoice_header_valid?
      return false unless @invoice_header.keys.all? do |key|
        %i[invoice_number invoice_series_code invoice_document_type invoice_class].include?(key)
      end

      true
    end

    def issue_data_valid?
      return false unless @issue_data.keys.all? do |key|
        %i[issue_date language_name invoice_currency_code].include?(key)
      end

      true
    end

    def totals_valid?
      return false unless @totals.keys.all? do |key|
        %i[total_gross_amount total_tax_outputs total_taxes_withheld invoice_total payment_on_account payment_due
           total_outstanding_amount total_executable_amount].include?(key)
      end

      true
    end

    def taxes_output_valid?
      return false unless @taxes_output.all?(&:valid?)

      true
    end

    def taxes_withheld_valid?
      return false unless @taxes_withheld.all?(&:valid?)

      true
    end

    def invoice_line_valid?
      return false unless @invoice_lines.all?(&:valid?)

      true
    end
  end
end
