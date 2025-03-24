# frozen_string_literal: true

require_relative "facturae/version"
require_relative "facturae/models/address"
require_relative "facturae/models/tax"
require_relative "facturae/models/subject"
require_relative "facturae/models/file_header"

module Facturae
  class Error < StandardError; end
end
