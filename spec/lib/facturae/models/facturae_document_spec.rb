# frozen_string_literal: true

module Facturae
  RSpec.describe FacturaeDocument do
    describe "#initialize" do
      let(:party) { instance_double(Party) }
      let(:facturae_document) { described_class.new(seller_party: party, buyer_party: party) }

      it "initializes all properties with expected values" do
        expect(facturae_document.file_header).to be_a(FileHeader)
        expect(facturae_document.invoices).to eq([])
        expect(facturae_document.seller_party).to eq(party)
        expect(facturae_document.buyer_party).to eq(party)
      end
    end
  end
end
