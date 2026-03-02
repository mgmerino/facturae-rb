# frozen_string_literal: true

module Facturae
  RSpec.describe Line do
    let(:line) do
      described_class.new(item_description: "Item description",
                          quantity: 1.0,
                          unit_price_without_tax: 10.0,
                          total_cost: 10.0,
                          unit_of_measure: "01")
    end

    describe "#initialize" do
      it "initializes all properties with expected values" do
        expect(line.item_description).to eq("Item description")
        expect(line.quantity).to eq(1.0)
        expect(line.unit_price_without_tax).to eq(10.0)
        expect(line.gross_amount).to eq(10.0) # computed: quantity * unit_price_without_tax
        expect(line.total_cost).to eq(10.0)
        expect(line.unit_of_measure).to eq("01")
      end
    end

    describe "#valid?" do
      context "when the line is valid" do
        let(:line) do
          described_class.new(item_description: "Item description",
                              quantity: 1.0,
                              unit_price_without_tax: 10.0,
                              total_cost: 10.0,
                              unit_of_measure: "01")
        end

        it "returns true" do
          expect(line.valid?).to be(true)
        end
      end

      context "when the line is not valid" do
        let(:line) do
          described_class.new(item_description: nil,
                              quantity: 1.0,
                              unit_price_without_tax: 10.0,
                              total_cost: 10.0,
                              unit_of_measure: "01")
        end

        it "returns false" do
          expect(line.valid?).to be(false)
        end
      end
    end

    describe "#errors" do
      it "returns empty array when valid" do
        line.valid?
        expect(line.errors).to be_empty
      end

      it "returns error when item_description is not a String" do
        line.item_description = 123
        line.valid?
        expect(line.errors).to include("item_description must be a String")
      end

      it "returns error when article_code is present but not a String" do
        line.article_code = 123
        line.valid?
        expect(line.errors).to include("article_code must be a String")
      end
    end
  end
end
