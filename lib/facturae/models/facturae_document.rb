# frozen_string_literal: true

module Facturae
  # Represents a Facturae document.
  # @attr [Facturae::FileHeader] file_header The file header.
  # @attr [Facturae::Party] seller_party The seller party.
  # @attr [Facturae::Party] buyer_party The buyer party.
  # @attr [Array<Facturae::Invoice>] invoices The invoices.
  class FacturaeDocument
    include Validatable

    attr_accessor :file_header,
                  :seller_party,
                  :buyer_party,
                  :invoices

    def initialize(file_header: FileHeader.new, seller_party: Party.new, buyer_party: Party.new)
      @file_header = file_header
      @seller_party = seller_party
      @buyer_party = buyer_party
      @invoices = []
    end

    def add_invoice(invoice)
      @invoices << invoice
    end

    private

    def validate
      super
      add_error("invoices must not be empty") if @invoices.empty?
      validate_seller_buyer_different
      validate_children("invoices", @invoices)
      validate_child("file_header", @file_header)
      validate_child("seller_party", @seller_party)
      validate_child("buyer_party", @buyer_party)
    end

    def validate_seller_buyer_different
      seller_tid = @seller_party&.tax_identification&.dig(:tax_id_number)
      buyer_tid = @buyer_party&.tax_identification&.dig(:tax_id_number)
      return unless seller_tid && buyer_tid && seller_tid == buyer_tid

      add_error("seller and buyer must have different tax_id_number")
    end
  end
end
