require 'helper'

module PersistentQueueClasses

  module MongoDB

    class QueueTest < MiniTest::Unit::TestCase

      #include QueueTests

      private

        def queue
          Queue.new
        end

    end

  end

end
