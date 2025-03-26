# frozen_string_literal: true

module Facturae
  RSpec.describe Address do
    let(:address) do
      described_class.new(address: "Cherry Blossom Av, 2",
                          post_code: "28002", town: "Madrid",
                          province: "Madrid", country_code: "ESP")
    end

    describe "#initialize" do
      it "init all properties with expected values" do
        expect(address.address).to eq("Cherry Blossom Av, 2")
        expect(address.post_code).to eq("28002")
        expect(address.town).to eq("Madrid")
        expect(address.province).to eq("Madrid")
        expect(address.country_code).to eq("ESP")
      end
    end

    describe "#valid?" do
      context "when the address is valid" do
        it "returns true" do
          expect(address.valid?).to be(true)
        end
      end

      context "when the address is not valid" do
        it "returns false" do
          address.address = nil
          expect(address.valid?).to be(false)
        end
      end
    end
  end
end
