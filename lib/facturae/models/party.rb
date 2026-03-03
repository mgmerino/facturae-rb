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

    # Spanish NIF: 8 digits + check letter
    NIF_PATTERN = /\A\d{8}[A-Z]\z/
    # Spanish NIE: X/Y/Z + 7 digits + check letter
    NIE_PATTERN = /\A[XYZ]\d{7}[A-Z]\z/
    # Spanish CIF: letter + 7 digits + control (digit or letter A-J)
    CIF_PATTERN = /\A[ABCDEFGHJNPQRSUVW]\d{7}[0-9A-J]\z/

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
      validate_spanish_tax_id if tid[:residence_type_code] == TAX_RESIDENT
      validate_child("subject", @subject)
    end

    def validate_spanish_tax_id
      tid = @tax_identification
      nif = tid[:tax_id_number]
      return unless nif.is_a?(String)

      if tid[:person_type_code] == NATURAL_PERSON
        add_error("tax_id_number is not a valid NIF/NIE") unless nif.match?(NIF_PATTERN) || nif.match?(NIE_PATTERN)
      elsif tid[:person_type_code] == LEGAL_ENTITY
        add_error("tax_id_number is not a valid CIF") unless nif.match?(CIF_PATTERN)
      end
    end
  end
end
