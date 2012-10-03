require_relative 'queue'

module PersistentQueueClasses

  module Redis

    class SizedQueue < Queue

      attr_accessor :max

      def initialize(max, options={})
        @max = max
        super default_options.merge(options)
      end

    end

  end

end
