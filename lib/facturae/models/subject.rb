# frozen_string_literal: true

module Facturae
  class Subject
    INDIVIDUAL = :individual
    LEGAL = :legal
    TYPES = [INDIVIDUAL, LEGAL].freeze

    attr_accessor :type,
                  :name_field1,
                  :name_field2,
                  :address_in_spain,
                  :overseas_address # Optional

    def initialize(type:, name_field1:, name_field2:, address_in_spain: Address.new)
      @type = type
      @name_field1 = name_field1
      @name_field2 = name_field2
      @address_in_spain = address_in_spain
    end
  end
end
