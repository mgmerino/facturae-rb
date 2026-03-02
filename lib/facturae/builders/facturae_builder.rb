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

    FACTURAE_NAMESPACE = "http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml"
    XMLDSIG_NAMESPACE = "http://www.w3.org/2000/09/xmldsig#"

    def to_xml
      doc = Nokogiri::XML(build_xml_string)
      apply_namespaces(doc)
      doc.to_xml
    end

    private

    def build_xml_string
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.Facturae do
          FileHeaderBuilder.new(@facturae.file_header).build(xml)
          PartiesBuilder.new(@facturae.seller_party, @facturae.buyer_party).build(xml)
          InvoicesBuilder.new(@facturae.invoices).build(xml)
        end
      end.to_xml
    end

    def apply_namespaces(doc)
      fe_ns = doc.root.add_namespace_definition("fe", FACTURAE_NAMESPACE)
      doc.root.namespace = fe_ns
      doc.root.add_namespace_definition("ds", XMLDSIG_NAMESPACE)
    end
  end
end
