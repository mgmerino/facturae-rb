# frozen_string_literal: true

module Facturae
  # Metadata of the invoice
  #
  # @attr_reader [String] schema_version
  # @attr_accessor [String] modality
  # @attr_accessor [String] invoice_issuer_type
  # @attr_accessor [Hash] batch
  class FileHeader
    include Validatable

    SCHEMA_VERSION = "3.2.2"

    ISSUER = "EM"
    RECIPIENT = "RE"
    INVOICE_ISSUER_TYPES = [ISSUER, RECIPIENT].freeze

    INDIVIDUAL = "I"
    BATCH = "L"
    MODALITY_TYPES = [INDIVIDUAL, BATCH].freeze

    BATCH_KEYS = %i[invoices_count series_invoice_number total_invoice_amount total_tax_outputs total_tax_inputs
                    invoice_currency_code].freeze

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

    private

    def validate
      super
      add_error("modality must be I or L") unless MODALITY_TYPES.include?(@modality)
      add_error("invoice_issuer_type must be EM or RE") unless INVOICE_ISSUER_TYPES.include?(@invoice_issuer_type)
      validate_batch
    end

    def validate_batch
      invalid_keys = @batch.keys - BATCH_KEYS
      invalid_keys.each { |key| add_error("batch contains unknown key: #{key}") }
      add_error("batch.invoices_count must be an Integer") unless @batch[:invoices_count].is_a?(Integer)
      add_error("batch.total_invoice_amount must be a Float") unless @batch[:total_invoice_amount].is_a?(Float)
      add_error("batch.total_tax_outputs must be a Float") unless @batch[:total_tax_outputs].is_a?(Float)
      add_error("batch.total_tax_inputs must be a Float") unless @batch[:total_tax_inputs].is_a?(Float)
      add_error("batch.invoice_currency_code must be a String") unless @batch[:invoice_currency_code].is_a?(String)
    end
  end
end
