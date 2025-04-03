# frozen_string_literal: true

module Facturae
  RSpec.describe InvoicesBuilder do
    let(:invoice) { Invoice.new }
    let(:invoice_line) do
      Line.new(item_description: "item",
               quantity: 1,
               unit_price_without_tax: 1.0,
               gross_amount: 1.0,
               total_cost: 1.0,
               unit_of_measure: "01")
    end
    let(:tax) { Tax.new(tax_rate: 0.21, taxable_base: 1.0, tax_type_code: "01", tax_amount: 0.21) }
    let(:xml) { Nokogiri::XML::Builder.new }

    it "builds the XML representation of the invoices" do
      invoice.add_invoice_line(invoice_line)
      invoice.add_tax_output(tax)
      invoice.add_tax_withheld(tax)
      invoice_line.article_code = "1234567890123"
      invoice.valid? # sanity check

      described_class.new([invoice]).build(xml)

      expect(xml.to_xml).to eq(
        <<~XML
          <?xml version="1.0"?>
          <Invoices>
            <Invoice>
              <InvoiceHeader>
                <InvoiceNumber>unset</InvoiceNumber>
                <InvoiceSeriesCode>unset</InvoiceSeriesCode>
                <InvoiceDocumentType>unset</InvoiceDocumentType>
                <InvoiceClass>unset</InvoiceClass>
              </InvoiceHeader>
              <InvoiceIssueData>
                <IssueDate>2025-04-03</IssueDate>
                <InvoiceCurrencyCode>unset</InvoiceCurrencyCode>
                <LanguageName>unset</LanguageName>
              </InvoiceIssueData>
              <InvoiceTotals>
                <TotalGrossAmount>0.0</TotalGrossAmount>
                <TotalTaxOutputs>0.0</TotalTaxOutputs>
                <TotalTaxesWithheld>0.0</TotalTaxesWithheld>
                <InvoiceTotal>0.0</InvoiceTotal>
                <PaymentOnAccount>0.0</PaymentOnAccount>
                <PaymentDue>0.0</PaymentDue>
                <TotalOutstandingAmount>0.0</TotalOutstandingAmount>
                <TotalExecutableAmount>0.0</TotalExecutableAmount>
              </InvoiceTotals>
              <TaxesOutputs>
                <Tax>
                  <TaxTypeCode>01</TaxTypeCode>
                  <TaxRate>0.21</TaxRate>
                  <TaxableBase>
                    <TotalAmount>1.0</TotalAmount>
                  </TaxableBase>
                  <TaxAmount>
                    <TotalAmount>0.21</TotalAmount>
                  </TaxAmount>
                </Tax>
              </TaxesOutputs>
              <TaxesWithheld>
                <Tax>
                  <TaxTypeCode>01</TaxTypeCode>
                  <TaxRate>0.21</TaxRate>
                  <TaxableBase>
                    <TotalAmount>1.0</TotalAmount>
                  </TaxableBase>
                  <TaxAmount>
                    <TotalAmount>0.21</TotalAmount>
                  </TaxAmount>
                </Tax>
              </TaxesWithheld>
              <Items>
                <InvoiceLine>
                  <ItemDescription>item</ItemDescription>
                  <Quantity>1</Quantity>
                  <UnitOfMeasure>01</UnitOfMeasure>
                  <UnitPriceWithoutTax>1.0</UnitPriceWithoutTax>
                  <GrossAmount>1.0</GrossAmount>
                  <TotalCost>1.0</TotalCost>
                  <ArticleCode>1234567890123</ArticleCode>
                </InvoiceLine>
              </Items>
            </Invoice>
          </Invoices>
        XML
      )
    end
  end
end
