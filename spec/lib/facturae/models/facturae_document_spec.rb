# frozen_string_literal: true

module Facturae
  RSpec.describe FacturaeDocument do
    let(:buyer_party) { instance_double(Party, tax_identification: { tax_id_number: "B12345678" }) }
    let(:seller_party) { instance_double(Party, tax_identification: { tax_id_number: "A87654321" }) }
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
        let(:invoice) { instance_double(Invoice, valid?: true, errors: []) }
        before do
          allow(file_header).to receive_messages(valid?: true, errors: [])
          allow(seller_party).to receive_messages(valid?: true, errors: [])
          allow(buyer_party).to receive_messages(valid?: true, errors: [])
        end

        it "returns true" do
          facturae_document.add_invoice(invoice)
          expect(facturae_document.valid?).to be(true)
        end
      end

      context "when the Facturae document is not valid" do
        before do
          allow(file_header).to receive_messages(valid?: true, errors: [])
          allow(seller_party).to receive_messages(valid?: true, errors: [])
          allow(buyer_party).to receive_messages(valid?: true, errors: [])
        end

        it "returns false" do
          expect(facturae_document.valid?).to be(false)
        end
      end
    end

    describe "#errors" do
      it "returns empty array when valid" do
        allow(file_header).to receive_messages(valid?: true, errors: [])
        allow(seller_party).to receive_messages(valid?: true, errors: [])
        allow(buyer_party).to receive_messages(valid?: true, errors: [])
        invoice = instance_double(Invoice, valid?: true, errors: [])
        facturae_document.add_invoice(invoice)
        facturae_document.valid?
        expect(facturae_document.errors).to be_empty
      end

      it "returns error when invoices is empty" do
        allow(file_header).to receive_messages(valid?: true, errors: [])
        allow(seller_party).to receive_messages(valid?: true, errors: [])
        allow(buyer_party).to receive_messages(valid?: true, errors: [])
        facturae_document.valid?
        expect(facturae_document.errors).to include("invoices must not be empty")
      end

      it "returns nested child errors with dot-path" do
        allow(file_header).to receive_messages(valid?: true, errors: [])
        allow(seller_party).to receive_messages(valid?: false, errors: ["person_type_code must be F or J"])
        allow(buyer_party).to receive_messages(valid?: true, errors: [])
        invoice = instance_double(Invoice, valid?: true, errors: [])
        facturae_document.add_invoice(invoice)
        facturae_document.valid?
        expect(facturae_document.errors).to include("seller_party.person_type_code must be F or J")
      end

      it "returns error when seller and buyer have the same tax_id_number" do
        same_tid = { tax_id_number: "A12345678" }
        allow(seller_party).to receive(:tax_identification).and_return(same_tid)
        allow(buyer_party).to receive(:tax_identification).and_return(same_tid)
        allow(file_header).to receive_messages(valid?: true, errors: [])
        allow(seller_party).to receive_messages(valid?: true, errors: [])
        allow(buyer_party).to receive_messages(valid?: true, errors: [])
        invoice = instance_double(Invoice, valid?: true, errors: [])
        facturae_document.add_invoice(invoice)
        facturae_document.valid?
        expect(facturae_document.errors).to include("seller and buyer must have different tax_id_number")
      end

      it "does not return error when seller and buyer have different tax_id_numbers" do
        allow(file_header).to receive_messages(valid?: true, errors: [])
        allow(seller_party).to receive_messages(valid?: true, errors: [])
        allow(buyer_party).to receive_messages(valid?: true, errors: [])
        invoice = instance_double(Invoice, valid?: true, errors: [])
        facturae_document.add_invoice(invoice)
        facturae_document.valid?
        expect(facturae_document.errors).not_to include("seller and buyer must have different tax_id_number")
      end
    end
  end
end
