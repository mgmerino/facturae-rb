# frozen_string_literal: true

module Facturae
  RSpec.describe Subject do
    describe "#initialize" do
      let(:address_stub) { instance_double(Address) }
      let(:legal_subject) do
        described_class.new(type: :individual, name_field1: "John", name_field2: "Doe", address_in_spain: address_stub)
      end

      it "init all properties with expected values" do
        expect(legal_subject.type).to eq(:individual)
        expect(legal_subject.name_field1).to eq("John")
        expect(legal_subject.name_field2).to eq("Doe")
        expect(legal_subject.overseas_address).to be_nil
      end
    end

    describe "#errors" do
      let(:valid_address) do
        Address.new(address: "Street 1", post_code: "28001", town: "Madrid",
                    province: "Madrid", country_code: "ESP")
      end
      let(:subject) do
        described_class.new(type: :individual, name_field1: "John", name_field2: "Doe",
                            address_in_spain: valid_address)
      end

      it "returns empty array when valid" do
        subject.valid?
        expect(subject.errors).to be_empty
      end

      it "returns error for invalid type" do
        subject.type = :unknown
        subject.valid?
        expect(subject.errors).to include("type must be :individual or :legal")
      end

      it "returns nested address errors with dot-path" do
        valid_address.country_code = "USA"
        subject.valid?
        expect(subject.errors).to include("address_in_spain.country_code is not a valid EU country code")
      end

      context "when type is :individual" do
        it "requires name_field2 (FirstSurname)" do
          individual = described_class.new(type: :individual, name_field1: "John",
                                           address_in_spain: valid_address)
          individual.valid?
          expect(individual.errors).to include("name_field2 is required for individuals")
        end
      end

      context "when type is :legal" do
        it "does not require name_field2 (TradeName)" do
          legal = described_class.new(type: :legal, name_field1: "Company SL",
                                      address_in_spain: valid_address)
          legal.valid?
          expect(legal.errors).not_to include(a_string_matching(/name_field2/))
        end

        it "allows name_field2 when present" do
          legal = described_class.new(type: :legal, name_field1: "Company SL",
                                      name_field2: "Trade Name", address_in_spain: valid_address)
          legal.valid?
          expect(legal.errors).to be_empty
        end
      end
    end
  end
end
