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

## Acknowledgements

Props to Scott Reis for his work on Anemone's `queueadapter` branch which gave
me the first idea for the implementation of this Queue implementation.
