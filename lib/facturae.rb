# frozen_string_literal: true

require "nokogiri"

require_relative "facturae/version"
require_relative "facturae/models/address"
require_relative "facturae/models/facturae_document"
require_relative "facturae/models/file_header"
require_relative "facturae/models/invoice"
require_relative "facturae/models/line"
require_relative "facturae/models/party"
require_relative "facturae/models/subject"
require_relative "facturae/models/tax"
require_relative "facturae/builders/parties_builder"
require_relative "facturae/builders/file_header_builder"

module Facturae
  class Error < StandardError; end
end
