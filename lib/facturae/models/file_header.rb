# frozen_string_literal: true

module Facturae
  # Metadata of the invoice
  #
  # @attr_reader [String] schema_version
  # @attr_accessor [String] modality
  # @attr_accessor [String] invoice_issuer_type
  # @attr_accessor [Hash] batch
  class FileHeader
    SCHEMA_VERSION = "3.2.2"

    ISSUER = "EM"
    RECIPIENT = "RE"
    INVOICE_ISSUER_TYPES = [ISSUER, RECIPIENT].freeze

    INDIVIDUAL = "I"
    BATCH = "L"
    MODALITY_TYPES = [INDIVIDUAL, BATCH].freeze

    attr_accessor :modality,
                  :invoice_issuer_type,
                  :batch

    attr_reader :schema_version

    def initialize(modality:, invoice_issuer_type:, batch: nil)
      @schema_version = SCHEMA_VERSION
      @modality = modality
      @invoice_issuer_type = invoice_issuer_type
      @batch = batch || {
        invoices_count: 1,
        series_invoice_number: nil,
        total_invoice_amount: 0.0,
        total_tax_outputs: 0.0,
        total_tax_inputs: 0.0,
        invoice_currency_code: "EUR"
      }
    end

    def valid?
      return false unless MODALITY_TYPES.include?(@modality)
      return false unless INVOICE_ISSUER_TYPES.include?(@invoice_issuer_type)
      return false unless batch_valid?

      true
    end

    private

    def batch_valid?
      return false unless @batch.keys.all? do |key|
        %i[invoices_count series_invoice_number total_invoice_amount total_tax_outputs total_tax_inputs
           invoice_currency_code].include?(key)
      end

      return false unless batch_fields_valid?

      true
    end

    def batch_fields_valid?
      return false unless @batch[:invoices_count].is_a?(Integer)
      return false unless @batch[:total_invoice_amount].is_a?(Float)
      return false unless @batch[:total_tax_outputs].is_a?(Float)
      return false unless @batch[:total_tax_inputs].is_a?(Float)
      return false unless @batch[:invoice_currency_code].is_a?(String)

      true
    end
  end
end
