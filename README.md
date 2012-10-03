# Ruby Persistent Queue Classes

A collection of Ruby classes that offer out-of-process, `Queue` compatible
implementations of Queues, deferring to engines such as Redis and MongoDB.

Supported Engines:

 * Redis
 * MongoDB

## Objective

The objective of this project is to provide disk-backed `Queue`
implementations for long-running operations where a `Queue` would typically be
used.

The original use-case was as pluggable "page queue" and "link queue"
implementations for the Anemone web crawler, of course these general purpose
classes can be used for anything where you might use a normal `Queue`.

## Supported Classes

 * Queue:      Redis, MongoDB
 * SizedQueue: Redis, MongoDB

## Requirements

The queues naturally enough need the Ruby gem for your desired backend, for
MongoDB that's the `mongo` Gem, for Redis that's simply `redis`.

The usual enhancements (`bson_ext`, for example) can be applied, require and
load those gems on your own side if you want the extra features/performance)

## Implementation

The Queues store objects by doing:

   `Base64.encode64(Marshal.dump(object))`

For that reason, you should not consider this portable between Ruby versions,
and obviously enough, you won't have a lot of success trying to connect Perl
or Python to the same queue.

## Blocking

The blocking reads/writes are achieved with `Thread.pass` and `until ...`
loops, this is quite possibly too naïve to be widely useful, but I haven't
personally had any problems, and the tests cover a variety of deadlock cases,
I think it's save.

## Connections

### Redis

Each queue uses two connections, the `redis` ruby gem blocks, so one cannot do
this:

    redis = Redis.new
    t1 = Thread.new { redis.blpop "somekey" }
    t2 = Thread.new { redis.get "someotherkey" }

The whole adapter is blocked by the `blpop` in the first thread, because of
that the Redis backed queue class will create two connections to the Redis
server, the second connection is established the first time something should
be popped from the queue, it is passed the same connection options as the
first connection.

## Atomicity

The queue classes rely on atomic operations from the underlying data stores,
and as such are relatively simple to implement in Ruby land, the backends
however must support atomic read/write operations.

## Collection Naming

### Redis

The collections for the Redis driver are named using the following scheme:

    {
      queue_key_name:   "persistent-queue-classes:redis:queue:#{self.hash.abs}:queue",
      waiting_key_name: "persistent-queue-classes:redis:queue:#{self.hash.abs}:waiting",
    }

The `waiting` key is used to store the number of threads waiting on a Queue,
this is a standard Redis key that is operated upon with `INCR` and `DECR`.

These can be overridden in the options hash passed to the options hash passed
to `PersistentQueueClasses::Redis::Queue.new`.

**Note:** When the last item is popped off the queue these keys are
**REMOVED**. This ensures that owing to the slightly strange naming scheme
(how useful are the object hash IDs, anyway?) that you do not completely
pollute the Redis keyspace with random queue names.

### MongoDB

## Acknowledgements

Props to Scott Reis for his work on Anemone's `queueadapter` branch which gave
me the first idea for the implementation of this Queue implementation.
