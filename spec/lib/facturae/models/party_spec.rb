# frozen_string_literal: true

module Facturae
  RSpec.describe Party do
    describe "#initialize" do
      let(:party) { described_class.new(subject:) }
      let(:subject) { instance_double(Subject) }

      it "init all properties with expected values" do
        expect(party.tax_identification).to a_hash_including(person_type_code: "F",
                                                             residence_type_code: "R",
                                                             tax_identification_number: "A12345678")
        expect(party.subject).to eq(subject)
      end
    end
  end
end
