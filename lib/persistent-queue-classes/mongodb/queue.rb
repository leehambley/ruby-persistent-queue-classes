begin
  require 'mongo'
rescue LoadError
  warn "To use the `PersistentQueueClasses::Mongo::Queue` please ensure the `mongo` and `bson_ext` gems are installed and on the load path."
  exit 1
end

module PersistentQueueClasses

  module MongoDB

    class Queue

      include PersistentQueueClasses::SharedQueueBehaviour

      def initialize(options={})
        @options = default_options.merge(options)
      end

      def clear
        connection.drop_database options[:database_name]
        [@collection, @waiting_collection, @connection, @database].map { |t| t = nil }
        []
      end

      def pop
        increment_waiting do
          until _r = collection.find_and_modify({ sort: {_id: Mongo::ASCENDING}, remove: true})
            Thread.stop
          end
          decode_object(_r["payload"])
        end
      end

      def push(object)
        collection.insert payload: encode_object(object)
      end

      def num_waiting
        waiting_collection.find(_id: 'WAITING').first["value"].to_i
      end

      def length
        collection.size
      end
      alias :size :length

      def empty?
        length == 0
      end

      private

      def increment_waiting &block
        waiting_collection.update({_id: 'WAITING'}, { "$inc" => { "value" => 1 } })
        yield
      ensure
        waiting_collection.update({_id: 'WAITING'}, { "$inc" => { "value" => -1 } })
      end

      def collection
        @collection ||= database[options[:queue_collection_name]].tap do |c|
          c.ensure_index :_id
        end
      end

      def waiting_collection
        @waiting_collection ||= database[options[:waiting_collection_name]].tap do |wc|
          wc.save({_id: :WAITING, value: 0})
        end
      end

      def connection
        @connection ||= Mongo::Connection.new options
      end

      def database
        @database ||= connection[options[:database_name]]
      end

      def default_options
        {
          database_name:           "persistent-queue-classes:mongodb:#{self.hash.abs}",
          queue_collection_name:   "queue",
          waiting_collection_name: "waiting",
          safe:                    true
        }
      end

    end

  end

end
