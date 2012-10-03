require 'base64'
begin
  require 'redis'
rescue LoadError
  warn "To use the `PersistentQueueClasses::Redis::Queue` please ensure the `redis` Gem is installed and on the load path."
  exit 1
end

module PersistentQueueClasses

  module Redis

    class Queue

      attr_reader :options, :redis

      def initialize(options={})
        @options = default_options.merge(options)
      end

      def length
        redis.llen(options[:queue_key_name]) || 0
      end
      alias :size :length

      def empty?
        length == 0
      end

      def num_waiting
        (redis.get(options[:waiting_key_name]) || 0).to_i
      end

      def push(object)
        redis.rpush options[:queue_key_name], Base64.encode64(Marshal.dump(object))
      end
      alias :enq :push
      alias :<< :push

      def pop
        redis.incr options[:waiting_key_name]
        key, object = bredis.blpop(options[:queue_key_name])
        Marshal.load(Base64.decode64(object))
      ensure
        redis.decr options[:waiting_key_name]
        clear if empty?
      end
      alias :deq :pop
      alias :shift :pop

      def clear
        r = redis.multi do
          redis.del options[:queue_key_name]
          redis.del options[:waiting_key_name]
        end
        return []
      end

      private

      def redis
        @redis ||= begin
          ::Redis.new(options).tap do |r|
            r.setnx options[:waiting_key_name], 0
          end
        end
      end

      def bredis
        @bredis ||= ::Redis.new(options)
      end

      def default_options
        {
          queue_key_name:   "persistent-queue-classes:redis:queue:#{self.hash.abs}:queue",
          waiting_key_name: "persistent-queue-classes:redis:queue:#{self.hash.abs}:waiting",
        }
      end

    end

  end

end
