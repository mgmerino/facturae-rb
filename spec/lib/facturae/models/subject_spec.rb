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
  end
end
