module RedisThreadRacingTests

  def test_thread_racing_memoization
    threads = 25.times.collect do
      Thread.new(queue) { |q| Thread.current[:redis] = q.redis }
    end
    threads.map(&:join)
    assert_equal 1, threads.collect { |t| t[:redis].object_id }.uniq.size
  end

end

module SizedQueueTests

  def test_max_reader
    assert_equal 2, queue.max
  end

  def test_max_writer
    queue.max = 15
    assert_equal 15, queue.max
  end

  def test_push_when_full_will_block
    queue.max = 1
    queue.push(:something)
    t1 = Thread.new(queue) do |q|
      q.push(:something_else)
    end
    Thread.new { sleep 0.1 }.join
    assert 1, queue.num_waiting
  ensure
    t1.kill
  end

end

module QueueTests

  def setup
    queue.clear
  end

  def test_that_it_responds_to_the_same_api_as_the_queue_class
    # Add Things
    assert queue.respond_to?(:enq)
    assert queue.respond_to?(:<<)
    assert queue.respond_to?(:push)

    # Remove Things
    assert queue.respond_to?(:deq)
    assert queue.respond_to?(:pop)
    assert queue.respond_to?(:shift)

    # Clean Up
    assert queue.respond_to?(:clear)
    assert queue.respond_to?(:empty?)

    # Size
    assert queue.respond_to?(:length)
    assert queue.respond_to?(:size)

    # Threads Waiting
    assert queue.respond_to?(:num_waiting)
  end

  def test_that_size_is_zero_when_no_threads_are_waiting
    assert_equal 0, queue.size
  end

  def test_that_length_is_zero_when_no_threads_are_waiting
    assert_equal 0, queue.length
  end

  def test_that_num_waiting_is_zero_when_no_threads_are_waiting
    assert_equal 0, queue.num_waiting
  end

  def test_queues_are_empty_when_new
    assert queue.empty?
  end

  def test_that_clear_returns_nil
    # It's not clear from the Ruby implementation why `clear` returns
    # an empty array.
    assert_equal [], queue.clear
  end

  def test_that_pop_should_block_when_the_queue_is_empty_increasing_num_waiting_by_one
    t_pop = Thread.new(queue) do |q|
      q.pop
    end
    Thread.new { sleep 0.5 }.join
    assert_equal 1, queue.num_waiting
  ensure
    t_pop.kill
  end

  def test_pop_no_block
    skip "Not Implemented Yet"
  end

  def test_that_pop_should_block_when_the_queue_is_empty_increasing_num_waiting_by_two
    t1_pop = Thread.new(queue) do |q|
      q.pop
    end
    t2_pop = Thread.new(queue) do |q|
      q.pop
    end
    Thread.new { sleep 0.5 }.join
    assert_equal 2, queue.num_waiting
  ensure
    [t1_pop, t2_pop].map(&:kill)
  end

  def test_fifo
    queue.push :first
    queue.push :second
    assert_equal :first, queue.pop
    assert_equal :second, queue.pop
  end

  def test_empty_after_clear
    queue.push :test
    refute queue.empty?
    queue.clear
    assert queue.empty?
  end

  def test_all_ruby_types_survive_the_push_and_pop_roundtrip
    [ 1, 1.5, "Test String", [:mixed, "array"], :symbol, /regex/ ].each do |object|
      queue.push object
      assert_equal object, queue.pop
    end
  end

end
