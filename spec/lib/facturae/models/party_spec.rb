# frozen_string_literal: true

module Facturae
  RSpec.describe Party do
    describe "#initialize" do
      let(:person_type_code) { "F" }
      let(:residence_type_code) { "R" }
      let(:tax_id_number) { "A12345678" }
      let(:party) { described_class.new(person_type_code:, residence_type_code:, tax_id_number:, subject:) }
      let(:subject) { instance_double(Subject) }

      it "init all properties with expected values" do
        expect(party.tax_identification).to a_hash_including(person_type_code: "F",
                                                             residence_type_code: "R",
                                                             tax_id_number: "A12345678")
        expect(party.subject).to eq(subject)
      end
    end

    describe "#errors" do
      let(:valid_address) do
        Address.new(address: "Street 1", post_code: "28001", town: "Madrid",
                    province: "Madrid", country_code: "ESP")
      end
      let(:valid_subject) do
        Subject.new(type: :individual, name_field1: "John", name_field2: "Doe",
                    address_in_spain: valid_address)
      end
      let(:valid_party) do
        described_class.new(person_type_code: "F", residence_type_code: "R",
                            tax_id_number: "A12345678", subject: valid_subject)
      end

      it "returns empty array when valid" do
        valid_party.valid?
        expect(valid_party.errors).to be_empty
      end

      it "returns error for invalid person_type_code" do
        valid_party.tax_identification[:person_type_code] = "X"
        valid_party.valid?
        expect(valid_party.errors).to include("person_type_code must be F or J")
      end

      it "returns nested subject errors with dot-path" do
        valid_party.subject.type = :unknown
        valid_party.valid?
        expect(valid_party.errors).to include("subject.type must be :individual or :legal")
      end

      context "when residence is Spanish (R)" do
        it "validates NIF format for natural persons" do
          party = described_class.new(
            person_type_code: "F", residence_type_code: "R",
            tax_id_number: "12345678Z", subject: valid_subject
          )
          party.valid?
          expect(party.errors).to be_empty
        end

        it "returns error for invalid NIF" do
          party = described_class.new(
            person_type_code: "F", residence_type_code: "R",
            tax_id_number: "INVALID", subject: valid_subject
          )
          party.valid?
          expect(party.errors).to include("tax_id_number is not a valid NIF/NIE")
        end

        it "validates NIE format for natural persons" do
          party = described_class.new(
            person_type_code: "F", residence_type_code: "R",
            tax_id_number: "X1234567L", subject: valid_subject
          )
          party.valid?
          expect(party.errors).to be_empty
        end

        it "validates CIF format for legal entities" do
          party = described_class.new(
            person_type_code: "J", residence_type_code: "R",
            tax_id_number: "B12345678",
            subject: Subject.new(type: :legal, name_field1: "Company SL", address_in_spain: valid_address)
          )
          party.valid?
          expect(party.errors).to be_empty
        end

        it "returns error for invalid CIF" do
          party = described_class.new(
            person_type_code: "J", residence_type_code: "R",
            tax_id_number: "123",
            subject: Subject.new(type: :legal, name_field1: "Company SL", address_in_spain: valid_address)
          )
          party.valid?
          expect(party.errors).to include("tax_id_number is not a valid CIF")
        end
      end

      context "when residence is not Spanish" do
        it "skips NIF/CIF format validation" do
          party = described_class.new(
            person_type_code: "F", residence_type_code: "E",
            tax_id_number: "FOREIGN123", subject: valid_subject
          )
          party.valid?
          expect(party.errors).not_to include(a_string_matching(/NIF|CIF/))
        end
      end
    end
  end
end
