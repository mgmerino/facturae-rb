# frozen_string_literal: true

module Facturae
  RSpec.describe Address do
    describe "#initialize" do
      let(:address) { described_class.new(address: "Cherry Blossom Av, 2", post_code: "01234", province: "Madrid") }

      it "init all properties with expected values" do
        expect(address.address).to eq("Cherry Blossom Av, 2")
        expect(address.post_code).to eq("01234")
        expect(address.town).to be_nil
        expect(address.province).to eq("Madrid")
        expect(address.country_code).to eq("ESP")
      end
    end
  end
end
