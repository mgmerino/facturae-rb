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

      it "returns error when item_description is empty" do
        line.item_description = ""
        line.valid?
        expect(line.errors).to include("item_description must not be empty")
      end

      it "returns error when item_description is only whitespace" do
        line.item_description = "   "
        line.valid?
        expect(line.errors).to include("item_description must not be empty")
      end

      it "returns error when total_cost does not equal quantity * unit_price_without_tax" do
        line.total_cost = 99.0
        line.valid?
        expect(line.errors).to include("total_cost must equal quantity * unit_price_without_tax")
      end

      it "accepts total_cost within 2-decimal precision" do
        l = described_class.new(item_description: "Test", quantity: 3.0, unit_price_without_tax: 1.333,
                                total_cost: 4.0)
        l.valid?
        expect(l.errors).not_to include("total_cost must equal quantity * unit_price_without_tax")
      end

      it "returns error when gross_amount does not equal total_cost - discounts + charges" do
        line.add_discount("Promo", 2.0)
        line.valid?
        expect(line.errors).to include("gross_amount must equal total_cost - discounts + charges")
      end

      it "accepts gross_amount when discounts and charges are accounted for" do
        l = described_class.new(item_description: "Test", quantity: 1.0, unit_price_without_tax: 100.0,
                                total_cost: 100.0)
        l.add_discount("Promo", 10.0)
        l.add_charge("Surcharge", 5.0)
        l.instance_variable_set(:@gross_amount, 95.0)
        l.valid?
        expect(l.errors).not_to include("gross_amount must equal total_cost - discounts + charges")
      end
    end
  end
end
