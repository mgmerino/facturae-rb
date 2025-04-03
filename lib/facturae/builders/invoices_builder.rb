# frozen_string_literal: true

module Facturae
  # Builds the XML representation of the invoices.
  class InvoicesBuilder
    def initialize(invoices)
      @invoices = invoices
    end

    def build(xml)
      xml.Invoices do |i_xml|
        build_invoices(i_xml, @invoices)
      end
    end

    private

    def build_invoices(xml, invoices)
      invoices.each do |invoice|
        build_invoice(xml, invoice)
      end
    end

    def build_invoice(xml, invoice)
      xml.Invoice do |invoice_xml|
        build_invoice_header(invoice_xml, invoice.invoice_header)
        build_invoice_issue_data(invoice_xml, invoice.issue_data)
        build_totals(invoice_xml, invoice.totals)
        build_taxes_outputs(invoice_xml, invoice.taxes_output)
        build_taxes_withheld(invoice_xml, invoice.taxes_withheld)
        build_invoice_lines(invoice_xml, invoice.invoice_lines)
      end
    end

    def build_invoice_header(xml, header_hash)
      xml.InvoiceHeader do
        xml.InvoiceNumber header_hash[:invoice_number]
        xml.InvoiceSeriesCode header_hash[:invoice_series_code] if header_hash[:invoice_series_code]
        xml.InvoiceDocumentType header_hash[:invoice_document_type]
        xml.InvoiceClass header_hash[:invoice_class]
      end
    end

    def build_invoice_issue_data(xml, issue_data)
      xml.InvoiceIssueData do
        xml.IssueDate issue_data[:issue_date].strftime("%Y-%m-%d") if issue_data[:issue_date]
        xml.InvoiceCurrencyCode(issue_data[:invoice_currency_code])
        xml.LanguageName issue_data[:language_name]
      end
    end

    def build_totals(xml, totals)
      xml.InvoiceTotals do
        xml.TotalGrossAmount totals[:total_gross_amount]
        xml.TotalTaxOutputs totals[:total_tax_outputs]
        xml.TotalTaxesWithheld totals[:total_taxes_withheld]
        xml.InvoiceTotal totals[:invoice_total]
        xml.PaymentOnAccount totals[:payment_on_account]
        xml.PaymentDue totals[:payment_due]
        xml.TotalOutstandingAmount totals[:total_outstanding_amount]
        xml.TotalExecutableAmount totals[:total_executable_amount]
      end
    end

    def build_taxes_outputs(xml, taxes_output)
      xml.TaxesOutputs do
        taxes_output.each do |tax|
          build_tax(xml, tax)
        end
      end
    end

    def build_taxes_withheld(xml, taxes_withheld)
      xml.TaxesWithheld do
        taxes_withheld.each do |tax|
          build_tax(xml, tax)
        end
      end
    end

    def build_tax(xml, tax)
      xml.Tax do
        xml.TaxTypeCode tax.tax_type_code
        xml.TaxRate tax.tax_rate
        xml.TaxableBase do
          xml.TotalAmount tax.taxable_base
        end
        xml.TaxAmount do
          xml.TotalAmount tax.tax_amount
        end
      end
    end

    def build_invoice_lines(xml, invoice_lines)
      xml.Items do
        invoice_lines.each do |invoice_line|
          build_invoice_line(xml, invoice_line)
        end
      end
    end

    def build_invoice_line(xml, invoice_line)
      xml.InvoiceLine do
        xml.ItemDescription invoice_line.item_description
        xml.Quantity invoice_line.quantity
        xml.UnitOfMeasure invoice_line.unit_of_measure
        xml.UnitPriceWithoutTax invoice_line.unit_price_without_tax
        xml.GrossAmount invoice_line.gross_amount
        xml.TotalCost invoice_line.total_cost
        xml.ArticleCode invoice_line.article_code
      end
    end
  end
end
