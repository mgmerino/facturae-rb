# frozen_string_literal: true

module Facturae
  class FileHeader
    SCHEMA_VERSION = "3.2.1"
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

    def initialize(modality: INDIVIDUAL, invoice_issuer_type: ISSUER)
      @schema_version = SCHEMA_VERSION
      @modality = modality
      @invoice_issuer_type = invoice_issuer_type
      @batch = {
        invoices_count: 1,
        series_invoice_number: nil,
        total_invoice_amount: 0.0,
        total_tax_outputs: 0.0,
        total_tax_inputs: 0.0,
        invoice_currency_code: "EUR"
      }
    end
  end
end
