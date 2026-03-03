# frozen_string_literal: true

module Facturae
  # Represents a legal subject, either an individual or a legal entity.
  # @attr [Symbol] type The type of subject.
  # @attr [String] name_field1 The first name field.
  # @attr [String] name_field2 The second name field.
  # @attr [Facturae::Address] address_in_spain The address in Spain.
  # @attr [Facturae::Address] overseas_address The overseas address. Optional.
  class Subject
    include Validatable

    INDIVIDUAL = :individual
    LEGAL = :legal
    SUBJECT_TYPES = [INDIVIDUAL, LEGAL].freeze

    attr_accessor :type,
                  :name_field1,
                  :name_field2,
                  :name_field3,
                  :address_in_spain,
                  :overseas_address # Optional

    def initialize(type:, name_field1:, name_field2: nil, name_field3: nil, address_in_spain: Address.new)
      @type = type
      @name_field1 = name_field1
      @name_field2 = name_field2
      @name_field3 = name_field3
      @address_in_spain = address_in_spain
    end

    private

    def validate
      super
      add_error("type must be :individual or :legal") unless SUBJECT_TYPES.include?(@type)
      add_error("name_field1 must be a String") unless @name_field1.is_a?(String)
      validate_name_field2
      validate_child("address_in_spain", @address_in_spain)
      validate_child("overseas_address", @overseas_address)
    end

    def validate_name_field2
      if @type == INDIVIDUAL
        add_error("name_field2 is required for individuals") unless @name_field2.is_a?(String)
      elsif @name_field2 && !@name_field2.is_a?(String)
        add_error("name_field2 must be a String")
      end
    end
  end
end
