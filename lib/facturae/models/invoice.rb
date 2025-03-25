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
                  :invoice_line

    def initialize
      @invoice_header = {
        invoice_number: nil,
        invoice_series_code: nil,
        invoice_document_type: "FC",
        invoice_class: "OO"
      }
      @issue_data = {
        issue_date: nil,
        language_name: "es",
        invoice_currency_code: "EUR"
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
      @invoice_line = []
    end

    def add_invoice_line(invoice_line)
      @invoice_line << invoice_line
    end

    def add_tax_output(tax)
      @taxes_output << tax
    end

    def add_tax_withheld(tax)
      @taxes_withheld << tax
    end
  end
end
