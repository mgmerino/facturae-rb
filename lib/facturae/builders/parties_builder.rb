# frozen_string_literal: true

module Facturae
  # Builds the XML representation of the parties.
  class PartiesBuilder
    def initialize(seller_party, buyer_party)
      @seller_party = seller_party
      @buyer_party  = buyer_party
    end

    def build(xml)
      xml.Parties do
        xml.SellerParty do
          build_party(xml, @seller_party)
        end
        xml.BuyerParty do
          build_party(xml, @buyer_party)
        end
      end
    end

    private

    def build_party(xml, party)
      xml.TaxIdentification do
        xml.PersonTypeCode party.tax_identification[:person_type_code]
        xml.ResidenceTypeCode party.tax_identification[:residence_type_code]
        xml.TaxIdentificationNumber party.tax_identification[:tax_id_number]
      end
      build_subject(xml, party.subject)
    end

    def build_subject(xml, subject_obj)
      if subject_obj.type == :individual
        xml.Individual do
          xml.Name subject_obj.name_field1
          xml.FirstSurname subject_obj.name_field2
          build_address_in_spain(xml, subject_obj.address_in_spain)
        end
      else
        xml.LegalEntity do
          xml.CorporateName subject_obj.name_field1
          xml.TradeName subject_obj.name_field2
          build_address_in_spain(xml, subject_obj.address_in_spain)
        end
      end
    end

    def build_address_in_spain(xml, address)
      return unless address

      xml.AddressInSpain do
        xml.Address     address.address
        xml.PostCode    address.post_code
        xml.Town        address.town
        xml.Province    address.province
        xml.CountryCode address.country_code
      end
    end
  end
end
