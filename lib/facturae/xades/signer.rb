# frozen_string_literal: true

require_relative "signed_info"
require_relative "key_info"
require_relative "object_info"
require "openssl"
require "base64"

module Facturae
  module Xades
    # Error class for XAdES signature validation failures.
    # @see XadesSigner#validate_xades_structure
    class SignatureError < StandardError; end

    # Handles the signing of XML documents using XAdES (XML Advanced Electronic Signatures).
    # This implementation follows the XAdES-BES profile and Facturae 3.2.2 specifications.
    #
    # The signing process follows these steps:
    # 1. Build the signature structure
    # 2. Canonicalize the SignedInfo
    # 3. Calculate the signature value
    # 4. Add all required XAdES elements
    # 5. Validate the complete structure
    #
    # @example
    #   xml_doc = Nokogiri::XML(xml_string)
    #   private_key = OpenSSL::PKey::RSA.new(key_file)
    #   certificate = OpenSSL::X509::Certificate.new(cert_file)
    #
    #   signer = Signer.new(xml_doc, private_key, certificate)
    #   signer.sign
    #
    # @raise [SignatureError] if the signature structure is invalid
    class Signer
      include Utils

      XADES_NAMESPACE = "http://uri.etsi.org/01903/v1.3.2#"
      XMLDSIG_NAMESPACE = "http://www.w3.org/2000/09/xmldsig#"
      C14N_METHOD_ALGORITHM = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
      SIGNATURE_METHOD_ALGORITHM = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"

      NAMESPACES = {
        "ds" => XMLDSIG_NAMESPACE,
        "xades" => XADES_NAMESPACE
      }.freeze

      # @return [Nokogiri::XML::Document] The XML document to sign
      # @return [String] The ID of the signature node
      # @return [String] The ID of the signed properties
      # @return [String] The ID of the signature object
      # @return [String] The ID of the reference
      # @return [String] The ID of the certificate
      # @return [String] The ID of the signature value
      # @return [String] The ID of the signed info
      attr_reader :xml_doc, :signature_id, :signed_properties_id, :signature_object_id,
                  :reference_id, :certificate_id, :signature_value_id, :signed_info_id

      # Initialize a new XAdES signer
      #
      # @param xml_doc [Nokogiri::XML::Document] The XML document to sign
      # @param private_key [OpenSSL::PKey::RSA] The private key for signing
      # @param certificate [OpenSSL::X509::Certificate] The X509 certificate
      # @param builders [Hash] Optional hash with builder classes for dependency injection
      def initialize(xml_doc, private_key, certificate, builders = {})
        @xml_doc = xml_doc
        @private_key = private_key
        @certificate = certificate
        @builders = builders

        @certificate_id = "Certificate#{rand_id}"
        @reference_id = "Reference-ID-#{rand_id}"
        @signature_id = "Signature#{rand_id}"
        @signature_object_id = "#{signature_id}-Object#{rand_id}"
        @signature_value_id = "SignatureValue#{rand_id}"
        @signed_info_id = "Signature-SignedInfo#{rand_id}"
        @signed_properties_id = "SignedPropertiesID#{rand_id}"

        # Register namespaces in the document
        register_namespaces
      end

      # Sign the XML document using XAdES
      #
      # @return [Nokogiri::XML::Node] The signature node
      # @raise [SignatureError] if the signature structure is invalid
      def sign
        signature_node = build_signature_node
        @xml_doc.root.add_child(signature_node)

        # Add the SignedInfo element to the signature node
        signed_info = build_signed_info
        raise SignatureError, "Missing SignedInfo" unless signed_info

        signature_node.add_child(signed_info)

        # Canonicalize SignedInfo
        canonicalized_signed_info = canonicalize(signed_info)

        # Calculate the signature
        signature_value = calculate_signature(canonicalized_signed_info)

        # Add SignatureValue element
        signature_value_node = build_signature_value_node(signature_value)
        signature_node.add_child(signature_value_node)

        # Add the KeyInfo element to the signature node
        key_info = build_key_info
        raise SignatureError, "Missing KeyInfo" unless key_info

        signature_node.add_child(key_info)

        # Add the ObjectInfo element to the signature node
        object_info = build_object_info
        raise SignatureError, "Missing QualifyingProperties" unless object_info

        signature_node.add_child(object_info)

        # Validate the final structure
        validate_xades_structure(signature_node)

        signature_node
      end

      private

      def register_namespaces
        # Add namespaces to the document root if they don't exist
        NAMESPACES.each do |prefix, uri|
          @xml_doc.root.add_namespace(prefix, uri) unless @xml_doc.namespaces.values.include?(uri)
        end
      end

      # Build the root signature node
      # @return [Nokogiri::XML::Node]
      def build_signature_node
        signature = @xml_doc.create_element("ds:Signature")
        signature["Id"] = @signature_id
        signature["xmlns:xades"] = XADES_NAMESPACE
        signature["xmlns:ds"] = XMLDSIG_NAMESPACE

        signature
      end

      # Canonicalize an XML node using C14N
      # @param node [Nokogiri::XML::Node] The node to canonicalize
      # @return [String] The canonicalized XML
      def canonicalize(node)
        # Create a new document to avoid modifying the original
        doc = Nokogiri::XML::Document.new
        doc.root = node.dup

        # Use exclusive canonicalization without comments
        # This will handle both whitespace normalization and namespaces properly
        doc.canonicalize(nil, nil, nil)
      end

      # Calculate the signature value
      # @param canonicalized_data [String] The canonicalized SignedInfo
      # @return [String] The Base64-encoded signature
      def calculate_signature(canonicalized_data)
        digest = OpenSSL::Digest.new("SHA1")
        signature = @private_key.sign(digest, canonicalized_data)
        Base64.strict_encode64(signature)
      end

      # Build the SignatureValue node
      # @param signature_value [String] The Base64-encoded signature value
      # @return [Nokogiri::XML::Node]
      def build_signature_value_node(signature_value)
        signature_value_node = @xml_doc.create_element("ds:SignatureValue", signature_value)
        signature_value_node["Id"] = @signature_value_id
        signature_value_node
      end

      def build_signed_info
        signed_info_builder = @builders[:signed_info] || SignedInfo
        signed_info_builder.new(@xml_doc, { signed_info_id: }).build
      end

      def build_key_info
        key_info_builder = @builders[:key_info] || KeyInfo
        key_info_builder.new(@xml_doc, @certificate, { certificate_id: }).build
      end

      def build_object_info
        object_info_builder = @builders[:object_info] || ObjectInfo
        object_info_builder.new(@xml_doc, @certificate,
                                { signature_id:, signed_properties_id:, signature_object_id:, reference_id: }).build
      end

      # Validate the complete XAdES structure
      # @param signature_node [Nokogiri::XML::Node] The signature node to validate
      # @raise [SignatureError] if any validation fails
      def validate_xades_structure(signature_node)
        validate_signature_attributes(signature_node)
        validate_signed_info(signature_node)
        validate_signature_value(signature_node)
        validate_key_info(signature_node)
        validate_qualifying_properties(signature_node)
      end

      # Validate the signature node attributes
      # @raise [SignatureError] if the Id or namespace is missing
      def validate_signature_attributes(node)
        raise SignatureError, "Missing Signature Id" unless node["Id"] == @signature_id
        raise SignatureError, "Missing XAdES namespace" unless node["xmlns:xades"] == XADES_NAMESPACE
      end

      # Validate the SignedInfo structure
      # @raise [SignatureError] if any required element is missing or invalid
      def validate_signed_info(signature_node)
        signed_info = signature_node.at_xpath(".//ds:SignedInfo", NAMESPACES)
        raise SignatureError, "Missing SignedInfo" unless signed_info
        raise SignatureError, "Missing SignedInfo Id" unless signed_info["Id"] == @signed_info_id

        # Validate CanonicalizationMethod
        c14n = signed_info.at_xpath(".//ds:CanonicalizationMethod", NAMESPACES)
        raise SignatureError, "Missing CanonicalizationMethod" unless c14n
        raise SignatureError, "Invalid CanonicalizationMethod" unless c14n["Algorithm"] == C14N_METHOD_ALGORITHM

        # Validate SignatureMethod
        sig_method = signed_info.at_xpath(".//ds:SignatureMethod", NAMESPACES)
        raise SignatureError, "Missing SignatureMethod" unless sig_method
        raise SignatureError, "Invalid SignatureMethod" unless sig_method["Algorithm"] == SIGNATURE_METHOD_ALGORITHM

        # Validate References
        references = signed_info.xpath(".//ds:Reference", NAMESPACES)
        raise SignatureError, "Missing References" unless references.size == 3
      end

      # Validate the SignatureValue
      # @raise [SignatureError] if the signature value is missing or empty
      def validate_signature_value(signature_node)
        sig_value = signature_node.at_xpath(".//ds:SignatureValue", NAMESPACES)
        raise SignatureError, "Missing SignatureValue" unless sig_value
        raise SignatureError, "Missing SignatureValue Id" unless sig_value["Id"] == @signature_value_id
        raise SignatureError, "Empty SignatureValue" if sig_value.content.empty?
      end

      # Validate the KeyInfo structure
      # @raise [SignatureError] if any certificate or key information is missing
      def validate_key_info(signature_node)
        key_info = signature_node.at_xpath(".//ds:KeyInfo", NAMESPACES)
        raise SignatureError, "Missing KeyInfo" unless key_info
        raise SignatureError, "Missing KeyInfo Id" unless key_info["Id"] == @certificate_id

        # Validate X509Data
        x509 = key_info.at_xpath(".//ds:X509Certificate", NAMESPACES)
        raise SignatureError, "Missing X509Certificate" unless x509
        raise SignatureError, "Empty X509Certificate" if x509.content.empty?

        # Validate KeyValue
        key_value = key_info.at_xpath(".//ds:KeyValue/ds:RSAKeyValue", NAMESPACES)
        raise SignatureError, "Missing RSAKeyValue" unless key_value
        raise SignatureError, "Missing Modulus" unless key_value.at_xpath(".//ds:Modulus", NAMESPACES)
        raise SignatureError, "Missing Exponent" unless key_value.at_xpath(".//ds:Exponent", NAMESPACES)
      end

      # Validate the XAdES QualifyingProperties
      # @raise [SignatureError] if any required XAdES property is missing
      def validate_qualifying_properties(signature_node)
        object_node = signature_node.at_xpath(".//ds:Object/xades:QualifyingProperties", NAMESPACES)
        raise SignatureError, "Missing QualifyingProperties" unless object_node
        raise SignatureError, "Invalid QualifyingProperties Target" unless object_node["Target"] == "##{@signature_id}"

        signed_props = object_node.at_xpath(".//xades:SignedProperties", NAMESPACES)
        raise SignatureError, "Missing SignedProperties" unless signed_props
        raise SignatureError, "Missing SignedProperties Id" unless signed_props["Id"] == @signed_properties_id

        validate_signed_signature_properties(signed_props)
      end

      # Validate the SignedSignatureProperties
      # @raise [SignatureError] if any required signature property is missing
      def validate_signed_signature_properties(signed_props)
        sig_props = signed_props.at_xpath(".//xades:SignedSignatureProperties", NAMESPACES)
        raise SignatureError, "Missing SignedSignatureProperties" unless sig_props

        # Required elements
        raise SignatureError, "Missing SigningTime" unless sig_props.at_xpath(".//xades:SigningTime", NAMESPACES)
        raise SignatureError, "Missing SigningCertificate" unless sig_props.at_xpath(".//xades:SigningCertificate",
                                                                                     NAMESPACES)
        raise SignatureError, "Missing SignaturePolicyIdentifier" unless sig_props.at_xpath(
          ".//xades:SignaturePolicyIdentifier", NAMESPACES
        )
        raise SignatureError, "Missing SignerRole" unless sig_props.at_xpath(".//xades:SignerRole", NAMESPACES)
      end

      def signing_ids
        {
          signature_id:,
          signed_properties_id:,
          signature_object_id:,
          reference_id:
        }
      end
    end
  end
end
