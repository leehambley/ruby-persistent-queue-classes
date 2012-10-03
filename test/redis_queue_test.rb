require 'helper'

module RedisQueueTests

  def test_when_the_queue_is_emptied_the_redis_keys_are_deleted
    waiting_key_name = 'test-waiting-key-is-removed'
    queue_key_name   = 'test-queue-key-is-removed'

    q = PersistentQueueClasses::Redis::Queue.new(waiting_key_name: waiting_key_name, queue_key_name: queue_key_name)

    q.push :test
    assert redis.exists(queue_key_name)
    assert redis.exists(waiting_key_name)

    q.pop
    refute redis.exists(queue_key_name)
    refute redis.exists(waiting_key_name)
  end

  private

  def redis
    @_redis ||= ::Redis.new
  end

end

module PersistentQueueClasses

  module Redis

    class QueueTest < MiniTest::Unit::TestCase

      include QueueTests
      include RedisQueueTests

      private

      def queue
        @_queue ||= Queue.new
      end

    end

    class SizedQueueTest < MiniTest::Unit::TestCase

      include QueueTests
      include SizedQueueTests
      include RedisQueueTests

      private

        def queue
          @_queue ||= SizedQueue.new(2)
        end

    end

  end

end
