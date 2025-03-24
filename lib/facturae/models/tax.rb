# frozen_string_literal: true

module Facturae
  class Tax
    TAX_IVA = "01"
    TAX_IPSI = "02"
    TAX_IGIC = "03"
    TAX_IRPF = "04"
    TAX_OTHER = "05"
    TAX_ITPAJD = "06"
    TAX_IE = "07"
    TAX_RA = "08"
    TAX_IGTECM = "09"
    TAX_IECDPCAC = "10"
    TAX_IIIMAB = "11"
    TAX_ICIO = "12"
    TAX_IMVDN = "13"
    TAX_IMSN = "14"
    TAX_IMGSN = "15"
    TAX_IMPN = "16"
    TAX_REIVA = "17"
    TAX_REIGIC = "18"
    TAX_REIPSI = "19"
    TAX_IPS = "20"
    TAX_RLEA = "21"
    TAX_IVPEE = "22"
    TAX_IPCNG = "23"
    TAX_IACNG = "24"
    TAX_IDEC = "25"
    TAX_ILTCAC = "26"
    TAX_IGFEI = "27"
    TAX_IRNR = "28"
    TAX_ISS = "29"

    TAXES_TYPES = [TAX_IVA, TAX_IPSI, TAX_IGIC, TAX_IGIC, TAX_IRPF, TAX_OTHER, TAX_ITPAJD,
                   TAX_IE, TAX_RA, TAX_IGTECM, TAX_IECDPCAC, TAX_IIIMAB, TAX_ICIO,
                   TAX_IMVDN, TAX_IMSN, TAX_IMGSN, TAX_IMPN, TAX_REIVA, TAX_REIGIC,
                   TAX_REIPSI, TAX_IPS, TAX_RLEA, TAX_IVPEE, TAX_IPCNG, TAX_IACNG,
                   TAX_IDEC, TAX_ILTCAC, TAX_IGFEI, TAX_IRNR, TAX_ISS].freeze

    attr_accessor :tax_type_code,
                  :tax_rate,
                  :taxable_base

    def initialize(tax_type_code: TAX_IVA, tax_rate:, taxable_base:)
      @tax_type_code = tax_type_code
      @tax_rate = tax_rate
      @taxable_base = taxable_base
    end
  end
end
