# frozen_string_literal: true

module Facturae
  # Represents a Facturae document.
  # @attr [Facturae::FileHeader] file_header The file header.
  # @attr [Facturae::Party] seller_party The seller party.
  # @attr [Facturae::Party] buyer_party The buyer party.
  # @attr [Array<Facturae::Invoice>] invoices The invoices.
  class FacturaeDocument
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

    def valid?
      return false if @invoices.empty?
      return false if @invoices.any? { |invoice| !invoice.valid? }
      return false unless @file_header.valid?
      return false unless @seller_party.valid?
      return false unless @buyer_party.valid?

      true
    end
  end
end
