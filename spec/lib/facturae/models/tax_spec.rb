# frozen_string_literal: true

module Facturae
  RSpec.describe Tax do
    let(:tax) do
      described_class.new(tax_type_code: Tax::TAX_IVA, tax_rate: 0.21, tax_amount: 0.21, taxable_base: 0.1)
    end

    describe "#initialize" do
      it "init all properties with expected values" do
        expect(tax.tax_type_code).to eq("01")
        expect(tax.tax_rate).to eq(0.21)
        expect(tax.taxable_base).to eq(0.1)
      end
    end

    describe "#valid?" do
      context "when the tax is valid" do
        it "returns true" do
          expect(tax.valid?).to be(true)
        end
      end

      context "when the tax is not valid" do
        it "returns false" do
          tax.tax_type_code = nil
          expect(tax.valid?).to be(false)
        end
      end
    end

    describe "#errors" do
      it "returns empty array when valid" do
        tax.valid?
        expect(tax.errors).to be_empty
      end

      it "returns error for invalid tax_type_code" do
        tax.tax_type_code = "ZZ"
        tax.valid?
        expect(tax.errors).to include("tax_type_code is not a valid tax type")
      end

      it "returns error when tax_rate is not a Float" do
        tax.tax_rate = "bad"
        tax.valid?
        expect(tax.errors).to include("tax_rate must be a Float")
      end

      it "returns multiple errors" do
        tax.tax_type_code = nil
        tax.tax_rate = nil
        tax.valid?
        expect(tax.errors).to include("tax_type_code is not a valid tax type", "tax_rate must be a Float")
      end
    end
  end
end
