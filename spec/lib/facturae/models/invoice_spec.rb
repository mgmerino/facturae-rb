# frozen_string_literal: true

module Facturae
  RSpec.describe Invoice do
    describe "#initialize" do
      it "initializes all properties with expected values" do
        invoice = described_class.new

        expect(invoice.invoice_header).to a_hash_including(invoice_number: nil,
                                                           invoice_series_code: nil,
                                                           invoice_document_type: "FC",
                                                           invoice_class: "OO")
        expect(invoice.issue_data).to a_hash_including(issue_date: nil,
                                                       language_name: "es",
                                                       invoice_currency_code: "EUR")
        expect(invoice.totals).to a_hash_including(total_gross_amount: 0.0,
                                                   total_tax_outputs: 0.0,
                                                   total_taxes_withheld: 0.0,
                                                   invoice_total: 0.0,
                                                   payment_on_account: 0.0,
                                                   payment_due: 0.0,
                                                   total_outstanding_amount: 0.0,
                                                   total_executable_amount: 0.0)
        expect(invoice.taxes_output).to eq([])
        expect(invoice.taxes_withheld).to eq([])
        expect(invoice.invoice_line).to eq([])
      end
    end
  end
end
