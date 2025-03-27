# frozen_string_literal: true

module Facturae
  # Builds the XML representation of the file header.
  # @attr_reader [Facturae::FileHeader] file_header The file header.
  class FileHeaderBuilder
    def initialize(file_header)
      @file_header = file_header
    end

    # rubocop:disable Metrics/AbcSize
    def build(xml, file_header = @file_header)
      # reason for passing file_header as an argument:
      # we need to copy the instance variable to a local one,
      # as the block will be executed in a different context
      # (blame instance_eval: https://github.com/sparklemotion/nokogiri/blob/main/lib/nokogiri/xml/builder.rb#L329)
      batch_hash = file_header.batch

      xml.FileHeader do
        xml.SchemaVersion(file_header.schema_version)
        xml.Modality(file_header.modality)
        xml.InvoiceIssuerType(file_header.invoice_issuer_type)
        xml.Batch do
          xml.SeriesInvoiceNumber(batch_hash[:series_invoice_number])
          xml.InvoicesCount(batch_hash[:invoices_count])
          xml.TotalInvoicesAmount do
            xml.TotalAmount(batch_hash[:total_invoice_amount])
          end
          xml.TotalOutstandingAmount do
            xml.TotalAmount(batch_hash[:total_tax_outputs])
          end
          xml.TotalExecutableAmount do
            xml.TotalAmount(batch_hash[:total_tax_inputs])
          end
          xml.InvoiceCurrencyCode(batch_hash[:invoice_currency_code])
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
