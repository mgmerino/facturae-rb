# frozen_string_literal: true

module Facturae
  RSpec.describe FileHeaderBuilder do
    describe "#build" do
      let(:batch) do
        {
          series_invoice_number: "FA0000",
          invoices_count: 1,
          total_invoice_amount: 100.0,
          total_tax_outputs: 21.0,
          total_tax_inputs: 18.0,
          invoice_currency_code: "EUR"
        }
      end
      let(:file_header) { FileHeader.new(modality: "I", invoice_issuer_type: "EM", batch:) }
      let(:builder) { described_class.new(file_header) }
      let(:xml) { Nokogiri::XML::Builder.new }

      it "builds the XML representation of the file header" do
        builder.build(xml)

        expect(xml.to_xml).to eq(
          <<~XML
            <?xml version="1.0"?>
            <FileHeader>
              <SchemaVersion>3.2.2</SchemaVersion>
              <Modality>I</Modality>
              <InvoiceIssuerType>EM</InvoiceIssuerType>
              <Batch>
                <SeriesInvoiceNumber>FA0000</SeriesInvoiceNumber>
                <InvoicesCount>1</InvoicesCount>
                <TotalInvoicesAmount>
                  <TotalAmount>100.0</TotalAmount>
                </TotalInvoicesAmount>
                <TotalOutstandingAmount>
                  <TotalAmount>21.0</TotalAmount>
                </TotalOutstandingAmount>
                <TotalExecutableAmount>
                  <TotalAmount>18.0</TotalAmount>
                </TotalExecutableAmount>
                <InvoiceCurrencyCode>EUR</InvoiceCurrencyCode>
              </Batch>
            </FileHeader>
          XML
        )
      end
    end
  end
end
