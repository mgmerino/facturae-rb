# frozen_string_literal: true

require_relative "file_header_builder"
require_relative "parties_builder"
require_relative "invoices_builder"

module Facturae
  # Builds the XML representation of the Facturae document.
  class FacturaeBuilder
    def initialize(facturae)
      @facturae = facturae
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.Facturae(xmlns: "http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml") do
          FileHeaderBuilder.new(@facturae.file_header).build(xml)
          PartiesBuilder.new(@facturae.seller_party, @facturae.buyer_party).build(xml)
          InvoicesBuilder.new(@facturae.invoices).build(xml)
        end
      end
      builder.to_xml
    end
  end
end
