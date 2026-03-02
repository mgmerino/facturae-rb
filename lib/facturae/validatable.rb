# frozen_string_literal: true

module Facturae
  module Validatable
    def valid?
      validate
      errors.empty?
    end

    def errors
      @errors || []
    end

    private

    def validate
      @errors = []
    end

    def add_error(message)
      @errors << message
    end

    def validate_child(name, child)
      return unless child

      child.valid?
      child.errors.each { |e| add_error("#{name}.#{e}") }
    end

    def validate_children(name, children)
      children.each_with_index do |child, i|
        child.valid?
        child.errors.each { |e| add_error("#{name}[#{i}].#{e}") }
      end
    end
  end
end
