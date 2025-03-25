# frozen_string_literal: true

require_relative "facturae/version"
require_relative "facturae/models/address"
require_relative "facturae/models/facturae_document"
require_relative "facturae/models/file_header"
require_relative "facturae/models/invoice"
require_relative "facturae/models/line"
require_relative "facturae/models/party"
require_relative "facturae/models/subject"
require_relative "facturae/models/tax"

module Facturae
  class Error < StandardError; end
end
