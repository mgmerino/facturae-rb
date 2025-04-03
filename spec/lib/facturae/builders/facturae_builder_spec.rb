# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Facturae
  RSpec.describe FacturaeBuilder do
    let(:overseas_address) do
      Address.new(address: "Seller Street", post_code: "01234", town: "Helsinki",
                  province: "Helsinki", country_code: "FIN")
    end
    let(:address_in_spain) do
      Address.new(address: "Buyer Street", post_code: "28002", town: "Madrid",
                  province: "Madrid", country_code: "ES")
    end

    let(:person_subject) do
      Subject.new(type: Subject::INDIVIDUAL, name_field1: "Buyer Name", name_field2: "Buyer Last Name",
                  name_field3: "Buyer Second Last Name", address_in_spain:)
    end

    let(:legal_subject) do
      Subject.new(type: Subject::LEGAL, name_field1: "Seller Company", name_field2: "Seller Company S.A.",
                  name_field3: "Seller Company S.L.", address_in_spain: nil)
    end

    let(:file_header) do
      FileHeader.new(
        modality: FileHeader::INDIVIDUAL,
        invoice_issuer_type: FileHeader::ISSUER,
        batch: {
          invoices_count: 1,
          series_invoice_number: "A001",
          total_invoice_amount: 100.0,
          total_tax_outputs: 20.0,
          total_tax_inputs: 5.0,
          invoice_currency_code: "EUR"
        }
      )
    end
    let(:seller_party) do
      Party.new(
        residence_type_code: Party::TAX_RESIDENT,
        person_type_code: Party::LEGAL_ENTITY,
        tax_id_number: "ES12345678A",
        subject: legal_subject
      )
    end
    let(:buyer_party) do
      Party.new(
        residence_type_code: Party::TAX_RESIDENT,
        person_type_code: Party::NATURAL_PERSON,
        tax_id_number: "ES87654321B",
        subject: person_subject
      )
    end
    let(:invoice_line) do
      Line.new(item_description: "Product 1",
               quantity: 1.0,
               unit_price_without_tax: 100.0,
               unit_of_measure: Line::UNIT_DEFAULT,
               gross_amount: 100.0,
               total_cost: 121.0)
    end
    let(:invoice) do
      Invoice.new(
        invoice_header: {
          invoice_number: "12345",
          invoice_series_code: "A",
          invoice_document_type: "F",
          invoice_class: "I"
        },
        issue_data: {
          issue_date: Date.new(2023, 10, 1),
          invoice_currency_code: "EUR",
          language_name: "es"
        },
        totals: {
          total_gross_amount: 100.0,
          total_tax_outputs: 20.0,
          total_taxes_withheld: 0.0,
          invoice_total: 120.0,
          payment_on_account: 0.0,
          payment_due: 0.0,
          total_outstanding_amount: 120.0,
          total_executable_amount: 120.0
        },
        taxes_output: [
          Tax.new(
            tax_type_code: "VAT",
            tax_rate: 21.0,
            taxable_base: 100.0,
            tax_amount: 21.0
          )
        ],
        taxes_withheld: [
          Tax.new(
            tax_type_code: "IRPF",
            tax_rate: 15.0,
            taxable_base: 100.0,
            tax_amount: 15.0
          )
        ],
        invoice_lines: [invoice_line]
      )
    end
    let(:facturae) do
      FacturaeDocument.new(
        file_header: file_header,
        seller_party: seller_party,
        buyer_party: buyer_party
      )
    end

    let(:builder) { described_class.new(facturae) }

    before do
      seller_party.subject.overseas_address = overseas_address
      facturae.add_invoice(invoice)
      invoice_line.article_code = "1234567"
    end

    describe "#to_xml" do
      it "builds the XML representation of the Facturae document" do
        xml = builder.to_xml

        expect(xml).to eq(
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <Facturae xmlns="http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml">
              <FileHeader>
                <SchemaVersion>3.2.2</SchemaVersion>
                <Modality>I</Modality>
                <InvoiceIssuerType>EM</InvoiceIssuerType>
                <Batch>
                  <BatchIdentifier>A001</BatchIdentifier>
                  <InvoicesCount>1</InvoicesCount>
                  <TotalInvoicesAmount>
                    <TotalAmount>100.0</TotalAmount>
                  </TotalInvoicesAmount>
                  <TotalOutstandingAmount>
                    <TotalAmount>20.0</TotalAmount>
                  </TotalOutstandingAmount>
                  <TotalExecutableAmount>
                    <TotalAmount>5.0</TotalAmount>
                  </TotalExecutableAmount>
                  <InvoiceCurrencyCode>EUR</InvoiceCurrencyCode>
                </Batch>
              </FileHeader>
              <Parties>
                <SellerParty>
                  <TaxIdentification>
                    <PersonTypeCode>J</PersonTypeCode>
                    <ResidenceTypeCode>R</ResidenceTypeCode>
                    <TaxIdentificationNumber>ES12345678A</TaxIdentificationNumber>
                  </TaxIdentification>
                  <LegalEntity>
                    <CorporateName>Seller Company</CorporateName>
                    <TradeName>Seller Company S.A.</TradeName>
                    <OverseasAddress>
                      <Address>Seller Street</Address>
                      <PostCodeAndTown>01234</PostCodeAndTown>
                      <Province>Helsinki</Province>
                      <CountryCode>FIN</CountryCode>
                    </OverseasAddress>
                  </LegalEntity>
                </SellerParty>
                <BuyerParty>
                  <TaxIdentification>
                    <PersonTypeCode>F</PersonTypeCode>
                    <ResidenceTypeCode>R</ResidenceTypeCode>
                    <TaxIdentificationNumber>ES87654321B</TaxIdentificationNumber>
                  </TaxIdentification>
                  <Individual>
                    <Name>Buyer Name</Name>
                    <FirstSurname>Buyer Last Name</FirstSurname>
                    <SecondSurname>Buyer Second Last Name</SecondSurname>
                    <AddressInSpain>
                      <Address>Buyer Street</Address>
                      <PostCode>28002</PostCode>
                      <Town>Madrid</Town>
                      <Province>Madrid</Province>
                      <CountryCode>ES</CountryCode>
                    </AddressInSpain>
                  </Individual>
                </BuyerParty>
              </Parties>
              <Invoices>
                <Invoice>
                  <InvoiceHeader>
                    <InvoiceNumber>12345</InvoiceNumber>
                    <InvoiceSeriesCode>A</InvoiceSeriesCode>
                    <InvoiceDocumentType>F</InvoiceDocumentType>
                    <InvoiceClass>I</InvoiceClass>
                  </InvoiceHeader>
                  <InvoiceIssueData>
                    <IssueDate>2023-10-01</IssueDate>
                    <InvoiceCurrencyCode>EUR</InvoiceCurrencyCode>
                    <LanguageName>es</LanguageName>
                  </InvoiceIssueData>
                  <InvoiceTotals>
                    <TotalGrossAmount>100.0</TotalGrossAmount>
                    <TotalTaxOutputs>20.0</TotalTaxOutputs>
                    <TotalTaxesWithheld>0.0</TotalTaxesWithheld>
                    <InvoiceTotal>120.0</InvoiceTotal>
                    <PaymentOnAccount>0.0</PaymentOnAccount>
                    <PaymentDue>0.0</PaymentDue>
                    <TotalOutstandingAmount>120.0</TotalOutstandingAmount>
                    <TotalExecutableAmount>120.0</TotalExecutableAmount>
                  </InvoiceTotals>
                  <TaxesOutputs>
                    <Tax>
                      <TaxTypeCode>VAT</TaxTypeCode>
                      <TaxRate>21.0</TaxRate>
                      <TaxableBase>
                        <TotalAmount>100.0</TotalAmount>
                      </TaxableBase>
                      <TaxAmount>
                        <TotalAmount>21.0</TotalAmount>
                      </TaxAmount>
                    </Tax>
                  </TaxesOutputs>
                  <TaxesWithheld>
                    <Tax>
                      <TaxTypeCode>IRPF</TaxTypeCode>
                      <TaxRate>15.0</TaxRate>
                      <TaxableBase>
                        <TotalAmount>100.0</TotalAmount>
                      </TaxableBase>
                      <TaxAmount>
                        <TotalAmount>15.0</TotalAmount>
                      </TaxAmount>
                    </Tax>
                  </TaxesWithheld>
                  <Items>
                    <InvoiceLine>
                      <ItemDescription>Product 1</ItemDescription>
                      <Quantity>1.0</Quantity>
                      <UnitOfMeasure>01</UnitOfMeasure>
                      <UnitPriceWithoutTax>100.0</UnitPriceWithoutTax>
                      <GrossAmount>100.0</GrossAmount>
                      <TotalCost>121.0</TotalCost>
                      <ArticleCode>1234567</ArticleCode>
                    </InvoiceLine>
                  </Items>
                </Invoice>
              </Invoices>
            </Facturae>
          XML
        )
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
