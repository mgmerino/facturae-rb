# frozen_string_literal: true

module Facturae
  # Represents a party.
  # @attr [String] tax_id The tax identification number.
  # @attr [Facturae::Subject] subject The subject.
  class Party
    include Validatable

    NATURAL_PERSON = "F"
    LEGAL_ENTITY = "J"
    PARTY_TYPES = [NATURAL_PERSON, LEGAL_ENTITY].freeze

    TAX_RESIDENT = "R"
    TAX_NON_RESIDENT = "E"
    TAX_UE_RESIDENT = "U"
    TAX_TYPES = [TAX_RESIDENT, TAX_NON_RESIDENT, TAX_UE_RESIDENT].freeze

    attr_accessor :tax_identification,
                  :subject

    def initialize(person_type_code:, residence_type_code:, tax_id_number:, subject: Subject.new)
      @tax_identification = {
        person_type_code: person_type_code,
        residence_type_code: residence_type_code,
        tax_id_number: tax_id_number
      }

      @subject = subject
    end

    private

    def validate
      super
      tid = @tax_identification
      add_error("person_type_code must be F or J") unless PARTY_TYPES.include?(tid[:person_type_code])
      add_error("residence_type_code must be R, E, or U") unless TAX_TYPES.include?(tid[:residence_type_code])
      add_error("tax_id_number must be a String") unless tid[:tax_id_number].is_a?(String)
      validate_child("subject", @subject)
    end
  end
end
