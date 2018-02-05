module Ralyxa
  module RequestEntities
    class SlotResolutionMatch
      attr_reader :id, :value

      def initialize(id, value)
        @id  = id  
        @value = value
      end

      def self.build(resolution_value)
        new(resolution_value.dig('value', 'id'), resolution_value.dig('value', 'name'))
      end
    end
  end
end
