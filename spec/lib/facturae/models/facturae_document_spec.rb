# frozen_string_literal: true

module Facturae
  RSpec.describe FacturaeDocument do
    let(:buyer_party) { instance_double(Party) }
    let(:seller_party) { instance_double(Party) }
    let(:file_header) { instance_double(FileHeader) }
    let(:facturae_document) { described_class.new(seller_party:, buyer_party:, file_header:) }

    describe "#initialize" do
      it "initializes all properties with expected values" do
        expect(facturae_document.invoices).to eq([])
        expect(facturae_document.seller_party).to eq(seller_party)
        expect(facturae_document.buyer_party).to eq(buyer_party)
        expect(facturae_document.file_header).to eq(file_header)
      end
    end

    describe "#add_invoice" do
      let(:invoice) { instance_double(Invoice) }

      it "adds an invoice to the invoices array" do
        facturae_document.add_invoice(invoice)
        expect(facturae_document.invoices).to eq([invoice])
      end
    end

    describe "#valid?" do
      context "when the Facturae document is valid" do
        let(:invoice) { instance_double(Invoice, valid?: true) }
        before do
          allow(file_header).to receive(:valid?).and_return(true)
          allow(seller_party).to receive(:valid?).and_return(true)
          allow(buyer_party).to receive(:valid?).and_return(true)
        end

        it "returns true" do
          facturae_document.add_invoice(invoice)
          expect(facturae_document.valid?).to be(true)
        end
      end

      context "when the Facturae document is not valid" do
        it "returns false" do
          expect(facturae_document.valid?).to be(false)
        end
      end
    end
  end
end
