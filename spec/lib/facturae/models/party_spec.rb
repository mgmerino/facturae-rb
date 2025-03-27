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
  end
end
