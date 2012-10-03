module PersistentQueueClasses

  module SharedQueueBehaviour

    attr_accessor :options

    def encode_object(object)
      Base64.encode64(Marshal.dump(object))
    end

    def decode_object(string)
      Marshal.load(Base64.decode64(string))
    end

  end

end

require_relative 'persistent-queue-classes/version'
require_relative 'persistent-queue-classes/mongodb/queue'
require_relative 'persistent-queue-classes/redis/queue'
require_relative 'persistent-queue-classes/redis/sized_queue'
