# frozen_string_literal: true

module Facturae
  RSpec.describe PartiesBuilder do
    describe "#build" do
      let(:seller_address) do
        Address.new(address: "Cherry Blossom, 123", post_code: "12345",
                    province: "Springfield", town: "Springfield", country_code: "ESP")
      end

      let(:buyer_address) do
        Address.new(address: "Cherry Blossom, 321", post_code: "54321",
                    province: "Shelbyville", town: "Shelbyville", country_code: "ESP")
      end

      let(:seller_subject) do
        Subject.new(type: Subject::LEGAL, name_field1: "Electronic Parts Provider, S.L.",
                    name_field2: "ELECPPSL", address_in_spain: seller_address)
      end

      let(:buyer_subject) do
        Subject.new(type: Subject::INDIVIDUAL, name_field1: "John",
                    name_field2: "Doe", address_in_spain: buyer_address)
      end

      let(:seller_party) do
        Party.new(person_type_code: "J", residence_type_code: "E",
                  tax_id_number: "A12345678", subject: seller_subject)
      end

      let(:buyer_party) do
        Party.new(person_type_code: "F", residence_type_code: "R",
                  tax_id_number: "A87654321", subject: buyer_subject)
      end

      it "builds the XML representation of the parties" do
        xml_data = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          PartiesBuilder.new(seller_party, buyer_party).build(xml)
        end.to_xml
        expect(xml_data).to eq(
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <Parties>
              <SellerParty>
                <TaxIdentification>
                  <PersonTypeCode>J</PersonTypeCode>
                  <ResidenceTypeCode>E</ResidenceTypeCode>
                  <TaxIdentificationNumber>A12345678</TaxIdentificationNumber>
                </TaxIdentification>
                <LegalEntity>
                  <CorporateName>Electronic Parts Provider, S.L.</CorporateName>
                  <TradeName>ELECPPSL</TradeName>
                  <AddressInSpain>
                    <Address>Cherry Blossom, 123</Address>
                    <PostCode>12345</PostCode>
                    <Town>Springfield</Town>
                    <Province>Springfield</Province>
                    <CountryCode>ESP</CountryCode>
                  </AddressInSpain>
                </LegalEntity>
              </SellerParty>
              <BuyerParty>
                <TaxIdentification>
                  <PersonTypeCode>F</PersonTypeCode>
                  <ResidenceTypeCode>R</ResidenceTypeCode>
                  <TaxIdentificationNumber>A87654321</TaxIdentificationNumber>
                </TaxIdentification>
                <Individual>
                  <Name>John</Name>
                  <FirstSurname>Doe</FirstSurname>
                  <AddressInSpain>
                    <Address>Cherry Blossom, 321</Address>
                    <PostCode>54321</PostCode>
                    <Town>Shelbyville</Town>
                    <Province>Shelbyville</Province>
                    <CountryCode>ESP</CountryCode>
                  </AddressInSpain>
                </Individual>
              </BuyerParty>
            </Parties>
          XML
        )
      end
    end
  end
end
