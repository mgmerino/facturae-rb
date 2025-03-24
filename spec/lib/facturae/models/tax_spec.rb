# frozen_string_literal: true

module Facturae
  RSpec.describe Tax do
    let(:tax) { described_class.new(tax_type_code: Tax::TAX_IVA, tax_rate: 0.21, taxable_base: 0.1) }

    describe "#initialize" do
      it "init all properties with expected values" do
        expect(tax.tax_type_code).to eq("01")
        expect(tax.tax_rate).to eq(0.21)
        expect(tax.taxable_base).to eq(0.1)
      end
    end
  end
end
