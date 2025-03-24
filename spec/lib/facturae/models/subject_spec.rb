# frozen_string_literal: true

module Facturae
  RSpec.describe Subject do
    describe "#initialize" do
      let(:legal_subject) do
        described_class.new(type: :individual, name_field1: "John", name_field2: "Doe", address_in_spain:)
      end
      let(:address_in_spain) { Address.new(address: "Cherry Blossom Av, 2", post_code: "01234", province: "Madrid") }

      it "init all properties with expected values" do
        expect(legal_subject.type).to eq(:individual)
        expect(legal_subject.name_field1).to eq("John")
        expect(legal_subject.name_field2).to eq("Doe")
        expect(legal_subject.address_in_spain).to be_a(Address)
        expect(legal_subject.overseas_address).to be_nil
      end
    end
  end
end
