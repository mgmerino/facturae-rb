# frozen_string_literal: true

module Facturae
  # Represents a party.
  # @attr [String] tax_id The tax identification number.
  # @attr [Facturae::Subject] subject The subject.
  class Party
    attr_accessor :tax_identification,
                  :subject

    def initialize(subject: Subject.new)
      @tax_identification = {
        person_type_code: nil,
        residence_type_code: nil,
        tax_identification_number: nil
      }

      @subject = subject
    end
  end
end
