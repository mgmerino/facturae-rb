# frozen_string_literal: true

module Facturae
  # Represents a party.
  # @attr [String] tax_id The tax identification number.
  # @attr [Facturae::Subject] subject The subject.
  class Party
    NATURAL_PERSON = "F"
    LEGAL_ENTITY = "J"
    PARTY_TYPES = [NATURAL_PERSON, LEGAL_ENTITY].freeze

    TAX_RESIDENT = "R"
    TAX_NON_RESIDENT = "E"
    TAX_UE_RESIDENT = "U"
    TAX_TYPES = [TAX_RESIDENT, TAX_NON_RESIDENT, TAX_UE_RESIDENT].freeze

    attr_accessor :tax_identification,
                  :subject

    def initialize(subject: Subject.new, tax_identification_number: "A12345678")
      @tax_identification = {
        person_type_code: NATURAL_PERSON,
        residence_type_code: TAX_RESIDENT,
        tax_identification_number: tax_identification_number
      }

      @subject = subject
    end

    def valid?
      return false unless tax_identification_valid?
      return false unless subject_valid?

      true
    end

    def tax_identification_valid?
      return false unless PARTY_TYPES.include?(@tax_identification[:person_type_code])
      return false unless TAX_TYPES.include?(@tax_identification[:residence_type_code])
      return false unless @tax_identification[:tax_identification_number].is_a?(String)

      true
    end

    def subject_valid?
      subject.valid?
    end
  end
end
