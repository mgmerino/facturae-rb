# frozen_string_literal: true

module Facturae
  RSpec.describe Invoice do
    let(:invoice) do
      described_class.new
    end

    describe "#initialize" do
      it "initializes all properties with expected values" do
        expect(invoice.invoice_header).to a_hash_including(invoice_number: "unset",
                                                           invoice_series_code: "unset",
                                                           invoice_document_type: "unset",
                                                           invoice_class: "unset")
        expect(invoice.issue_data).to a_hash_including(issue_date: a_kind_of(Date),
                                                       language_name: "unset",
                                                       invoice_currency_code: "unset")
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
        expect(invoice.invoice_lines).to eq([])
      end
    end

    describe "#add_invoice_line" do
      let(:invoice_line) { instance_double(Line) }
      let(:invoice) { described_class.new }

      it "adds an invoice line to the invoice_line array" do
        invoice.add_invoice_line(invoice_line)
        expect(invoice.invoice_lines).to eq([invoice_line])
      end
    end

    describe "#add_tax_output" do
      let(:tax) { instance_double(Tax) }
      let(:invoice) { described_class.new }

      it "adds a tax output to the taxes_output array" do
        invoice.add_tax_output(tax)
        expect(invoice.taxes_output).to eq([tax])
      end
    end

    describe "#add_tax_withheld" do
      let(:tax) { instance_double(Tax) }
      let(:invoice) { described_class.new }

      it "adds a tax withheld to the taxes_withheld array" do
        invoice.add_tax_withheld(tax)
        expect(invoice.taxes_withheld).to eq([tax])
      end
    end

    describe "#valid?" do
      let(:invoice) { described_class.new }

      context "when the invoice is valid" do
        it "returns true" do
          expect(invoice.valid?).to be(true)
        end
      end

      context "when the invoice is not valid" do
        it "returns false" do
          invoice.invoice_header[:invalid_key] = "123"
          expect(invoice.valid?).to be(false)
        end
      end
    end
  end
end
