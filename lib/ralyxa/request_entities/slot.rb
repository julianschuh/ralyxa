require_relative './slot_resolution_match'

module Ralyxa
  module RequestEntities
    RESOLUTION_STATUS_MATCH = 'ER_SUCCESS_MATCH'

    class Slot
      attr_reader :name, :value

      def initialize(name, value, resolutions)
        @name = name
        @value = value

        @resolutions = resolutions || []
      end

      def self.build(slot)
        new(slot.dig('name'), slot.dig('value'), slot.dig('resolutions', 'resolutionsPerAuthority'))
      end

      def resolves?(authority = nil)
        !first_successful_resolution(authority).nil?
      end

      def resolutions(authority = nil)
        return @resolution_matches if @resolution_matches
        values = first_successful_resolution(authority)&.dig('values') || []
        @resolution_matches = values.map do |resolution_value|
          SlotResolutionMatch.build(resolution_value)
        end
      end

      private

      def first_successful_resolution(authority)
        @resolutions.select do |res|
          authority.nil? or res['authority'] == authority
        end.reject do |res|
          res['status']['code'] != RESOLUTION_STATUS_MATCH
        end.first
      end
    end
  end
end
