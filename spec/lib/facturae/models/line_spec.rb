# frozen_string_literal: true

module Facturae
  RSpec.describe Line do
    describe "#initialize" do
      it "initializes all properties with expected values" do
        line = described_class.new(item_description: "Item description",
                                   quantity: 1,
                                   unit_price_without_tax: 10.0,
                                   gross_amount: 10.0,
                                   total_cost: 10.0)

        expect(line.item_description).to eq("Item description")
        expect(line.quantity).to eq(1)
        expect(line.unit_price_without_tax).to eq(10.0)
        expect(line.gross_amount).to eq(10.0)
        expect(line.total_cost).to eq(10.0)
      end
    end
  end
end
