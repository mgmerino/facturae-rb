# frozen_string_literal: true

module Facturae
  RSpec.describe FileHeader do
    describe "#initialize" do
      let(:file_header) do
        described_class.new(modality: "I",
                            invoice_issuer_type: "EM")
      end

      it "init all properties with expected values" do
        expect(file_header.schema_version).to eq("3.2.2")
        expect(file_header.modality).to eq("I")
        expect(file_header.invoice_issuer_type).to eq("EM")
        expect(file_header.batch).to a_hash_including(invoices_count: 1,
                                                      series_invoice_number: nil,
                                                      total_invoice_amount: 0.0,
                                                      total_tax_outputs: 0.0,
                                                      total_tax_inputs: 0.0,
                                                      invoice_currency_code: "EUR")
      end
    end

    describe "#valid?" do
      context "when the file header is valid" do
        it "returns true" do
          file_header = described_class.new(modality: "I",
                                            invoice_issuer_type: "EM")
          expect(file_header.valid?).to be(true)
        end
      end

      context "when the file header is not valid" do
        it "returns false" do
          file_header = described_class.new(modality: "invalid-one",
                                            invoice_issuer_type: "EM")
          expect(file_header.valid?).to be(false)
        end
      end

      context "when the batch is not valid" do
        it "returns false" do
          file_header = described_class.new(modality: "I",
                                            invoice_issuer_type: "EM",
                                            batch: { invoices_count: 1,
                                                     series_invoice_number: nil,
                                                     total_invoice_amount: 0.0,
                                                     total_tax_outputs: 0.0,
                                                     total_tax_inputs: 0.0,
                                                     invoice_currency_code: 1 })
          expect(file_header.valid?).to be(false)
        end
      end
    end

    describe "#errors" do
      it "returns empty array when valid" do
        fh = described_class.new(modality: "I", invoice_issuer_type: "EM")
        fh.valid?
        expect(fh.errors).to be_empty
      end

      it "returns error for invalid modality" do
        fh = described_class.new(modality: "X", invoice_issuer_type: "EM")
        fh.valid?
        expect(fh.errors).to include("modality must be I or L")
      end

      it "returns error for invalid batch field type" do
        fh = described_class.new(modality: "I", invoice_issuer_type: "EM",
                                 batch: { invoices_count: 1, series_invoice_number: nil,
                                          total_invoice_amount: 0.0, total_tax_outputs: 0.0,
                                          total_tax_inputs: 0.0, invoice_currency_code: 1 })
        fh.valid?
        expect(fh.errors).to include("batch.invoice_currency_code must be a String")
      end
    end
  end
end
