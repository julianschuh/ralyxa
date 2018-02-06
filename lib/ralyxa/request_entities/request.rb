require 'json'
require 'forwardable'
require 'alexa_verifier'
require_relative './user'
require_relative './slot'

module Ralyxa
  module RequestEntities
    class Request
      extend Forwardable
      INTENT_REQUEST_TYPE = 'IntentRequest'.freeze

      def_delegator :@user, :id, :user_id
      def_delegator :@user, :access_token, :user_access_token
      def_delegator :@user, :access_token_exists?, :user_access_token_exists?

      def initialize(original_request, user_class = Ralyxa::RequestEntities::User)
        @request = JSON.parse(original_request.body.read)
        attempt_to_rewind_request_body(original_request)

        @user = user_class.build(@request)

        validate_request(original_request) if Ralyxa.configuration.validate_requests?
      end

      def intent_name
        return @request['request']['type'] unless intent_request?
        @request['request']['intent']['name']
      end

      def slot_value(slot_name)
        @request['request']['intent']['slots'][slot_name]['value']
      end

      def slot(slot_name)
        slots.select { |slot| slot.name == slot_name }.first
      end

      def slots
        @slots ||= @request['request']['intent']['slots'].values.map do |slot|
          Ralyxa::RequestEntities::Slot.build(slot)
        end
      end

      def new_session?
        @request['session']['new']
      end

      def session_id
        @request['session']['sessionId']
      end

      def session_attribute(attribute_name)
        @request['session']['attributes'][attribute_name]
      end

      def device_id
        @request.dig('context', 'System', 'device', 'deviceId')
      end

      def api
        {
          endpoint: @request.dig('context', 'System', 'apiEndpoint'),
          access_token: @request.dig('context', 'System', 'apiAccessToken')
        }
      end

      private

      def intent_request?
        @request['request']['type'] == INTENT_REQUEST_TYPE
      end

      def validate_request(request)
        AlexaVerifier.valid!(request)
      end

      def attempt_to_rewind_request_body(original_request)
        original_request.body&.rewind
      end
    end
  end
end
