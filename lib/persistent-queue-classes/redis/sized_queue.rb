require_relative 'queue'

module PersistentQueueClasses

  module Redis

    class SizedQueue < Queue

      attr_accessor :max

      def initialize(max, options={})
        @max = max
        super default_options.merge(options)
      end

      def push(obj)
        redis.incr options[:waiting_key_name]
        Thread.pass until length < max if length == max
        bredis.rpush options[:queue_key_name], encode_object(obj)
      ensure
        redis.decr options[:waiting_key_name]
      end

    end

  end

end
