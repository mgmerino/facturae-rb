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

      context "when the country code is not valid" do
        it "returns false" do
          address.country_code = "USA"
          expect(address.valid?).to be(false)
        end
      end

      context "when the country code is ESP and the town is nil" do
        it "returns false" do
          address.country_code = "ESP"
          address.town = nil
          expect(address.valid?).to be(false)
        end
      end
    end

    describe "#errors" do
      it "returns empty array when valid" do
        address.valid?
        expect(address.errors).to be_empty
      end

      it "returns error when address is nil" do
        address.address = nil
        address.valid?
        expect(address.errors).to include("address is required")
      end

      it "returns error when country_code is invalid" do
        address.country_code = "USA"
        address.valid?
        expect(address.errors).to include("country_code is not a valid EU country code")
      end

      it "returns error when town is nil for ESP" do
        address.town = nil
        address.valid?
        expect(address.errors).to include("town is required when country_code is ESP")
      end

      it "returns multiple errors" do
        address.address = nil
        address.country_code = "USA"
        address.valid?
        expect(address.errors).to include("address is required", "country_code is not a valid EU country code")
      end
    end
  end
end
