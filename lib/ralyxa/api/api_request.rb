require 'json'
require 'faraday'

module Ralyxa
  module Api
    REQUEST_TYPE_ADDRESS            = 'address'.freeze
    REQUEST_TYPE_COUNTRY_AND_POSTAL = 'address/countryAndPostalCode'.freeze

    class ApiRequest
      def initialize(request_type, request, options)
        @request_type = request_type
        @request = request
        @options = options
      end

      def self.perform(request_type, request, options = {})
        new(request_type, request, options).perform
      end

      def perform
        url = construct_url
        return nil unless url

        conn = Faraday.new(url: @request.api[:endpoint]) do |faraday|
          faraday.headers['Accept'] = 'application/json'
          faraday.headers['Authorization'] = 'Bearer ' + @request.api[:access_token]
          faraday.adapter Faraday.default_adapter
        end

        response = conn.get(url)

        return nil unless response.status == 200
        JSON.parse(response.body)
      end

      private

      def construct_url
        case @request_type
        when REQUEST_TYPE_ADDRESS
          "/v1/devices/" + @request.device_id + "/settings/address"
        when REQUEST_TYPE_COUNTRY_AND_POSTAL
          "/v1/devices/" + @request.device_id + "/settings/address/countryAndPostalCode"
        else
          nil
        end
      end
    end
  end
end
