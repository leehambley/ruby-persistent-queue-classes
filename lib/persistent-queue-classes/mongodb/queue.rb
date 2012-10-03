begin
  require 'mongo'
rescue LoadError
  warn "To use the `PersistentQueueClasses::Mongo::Queue` please ensure the `mongo` and `bson_ext` gems are installed and on the load path."
  exit 1
end

module PersistentQueueClasses

  module MongoDB

    class Queue

      attr_reader :options

      def initialize(options={})
        @options = default_options.merge(options)
      end

      private

      def default_options
        Hash.new
      end

    end

  end

end
