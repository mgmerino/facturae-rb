# frozen_string_literal: true

module Facturae
  # Represents a legal subject, either an individual or a legal entity.
  # @attr [Symbol] type The type of subject.
  # @attr [String] name_field1 The first name field.
  # @attr [String] name_field2 The second name field.
  # @attr [Facturae::Address] address_in_spain The address in Spain.
  # @attr [Facturae::Address] overseas_address The overseas address. Optional.
  class Subject
    INDIVIDUAL = :individual
    LEGAL = :legal
    SUBJECT_TYPES = [INDIVIDUAL, LEGAL].freeze

    attr_accessor :type,
                  :name_field1,
                  :name_field2,
                  :name_field3,
                  :address_in_spain,
                  :overseas_address # Optional

    def initialize(type:, name_field1:, name_field2:, name_field3: nil, address_in_spain: Address.new)
      @type = type
      @name_field1 = name_field1
      @name_field2 = name_field2
      @name_field3 = name_field3
      @address_in_spain = address_in_spain
    end

    def valid?
      return false unless SUBJECT_TYPES.include?(@type)
      return false unless @name_field1.is_a?(String)
      return false unless @name_field2.is_a?(String)
      return false unless @address_in_spain.valid?
      return false unless @overseas_address.nil? || @overseas_address.valid?

      true
    end
  end
end
