require 'savon'
require 'gyoku'

class EbayClient::Api < ActiveSupport::BasicObject
  attr_reader :configuration, :endpoint, :namespace, :header, :client, :calls

  def initialize configuration
    @configuration = configuration
    @endpoint = ::EbayClient::Endpoint.new configuration
    @namespace = :urn
    @header = ::EbayClient::Header.new configuration, namespace
    @client = ::Savon::Client.new configuration.wsdl_file
    @client.http.read_timeout = 600
    @calls = 0

    ::Gyoku.convert_symbols_to :camelcase
    create_methods if configuration.preload?
  end

  def dispatch name, body
    request = ::EbayClient::Request.new self, name, body

    @calls += 1
    request.execute
  end

  def inspect
    "<EbayClient::Api>"
  end
  alias_method :to_s, :inspect

  protected
  def create_methods
    api_methods = ::Module.new

    client.wsdl.soap_actions.each do |action|
      name = action.to_s.gsub(/e_bay_/, '_ebay_')

      api_methods.send :define_method, name do |*args|
        dispatch name, args.first
      end
    end

    api_methods.send :extend_object, self
  end

  def method_missing name, *args, &block
    dispatch name, args.first
  end
end
