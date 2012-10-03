$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'debugger'
require 'bundler/setup'
require 'turn/autorun'
require 'persistent-queue-classes'

require_relative 'queue_tests'

Thread.abort_on_exception = true

Turn.config.tap do |t|
  t.ansi = true
end
