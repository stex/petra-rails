module Petra
  module Rails
    module PersistenceAdapters
      class ActiveRecordAdapter < Petra::PersistenceAdapters::Adapter

        # TODO: change this to use e.g. the field accessors
        class << self
          def lock_type
            @lock_type || 'index_based'
          end

          def lock_type=(new_value)
            @lock_type = new_value
          end
        end

        def persist!
          return true if queue.empty?

          # We currently only allow entries for one transaction in the queue
          with_transaction_lock(queue.first.transaction_identifier) do
            while (entry = queue.shift) do
              identifier = persist_entry(entry)
              entry.mark_as_persisted!(identifier)
            end
          end
        end

        def transaction_identifiers
          with_global_lock do
            Petra::Rails::Section.distinct(:transaction_identifier).pluck(:transaction_identifier)
          end
        end

        def savepoints(transaction)
          with_transaction_lock(transaction) do
            Petra::Rails::Section.where(:transaction_identifier => transaction.identifier).pluck(:savepoint)
          end
        end

        def log_entries(section)
          with_transaction_lock(section.transaction) do
            section = Petra::Rails::Section.find_by(:savepoint => section.savepoint)
            return [] unless section

            section.log_entries.map do |entry|
              Petra::Components::LogEntry.from_hash(section, entry.fields)
            end
          end
        end

        #
        # Removes everything that was persisted while executing the given transaction
        #
        def reset_transaction(transaction)
          with_transaction_lock(transaction) do
            Petra::Rails::Section.where(:transaction_identifier => transaction.identifier).destroy_all
          end
        end

        #----------------------------------------------------------------
        #                           Locks
        #----------------------------------------------------------------

        def with_global_lock(**options, &block)
          with_database_lock('global.persistence', **options, &block)
        rescue Petra::LockError
          exception = Petra::LockError.new(lock_type: 'global', lock_name: 'global')
          raise exception, 'The global lock could not be acquired.'
        end

        def with_transaction_lock(transaction, **options, &block)
          identifier = transaction.is_a?(Petra::Components::Transaction) ? transaction.identifier : transaction
          with_database_lock("transaction.#{identifier}", **options, &block)
        rescue Petra::LockError
          exception = Petra::LockError.new(lock_type: 'transaction', lock_name: identifier)
          raise exception, "The transaction lock '#{identifier}' could not be acquired."
        end

        def with_object_lock(proxy, **options, &block)
          key = proxy.__object_key.gsub(/[^a-zA-Z0-9]/, '-')
          with_database_lock("proxy.#{key}", **options, &block)
        rescue Petra::LockError
          exception = Petra::LockError.new(lock_type: 'object', lock_name: proxy.__object_key)
          raise exception, "The object lock '#{proxy.__object_id}' could not be acquired."
        end

        private

        def persist_entry(entry)
          section = Petra::Rails::Section.first_or_create(transaction_identifier: entry.section.transaction.identifier,
                                                          savepoint:              entry.section.savepoint)

          section.log_entries.create do |record|
            record.update_attribute(:fields, entry.to_h(entry_identifier: record.id))
          end
        end

        def with_database_lock(identifier, suspend: true, &block)
          lock_identifier = identifier.to_s
          return block.call if (@held_locks ||= []).include?(lock_identifier)

          begin
            if suspend
              success = false
              success = sleep(1) && self.class.lock_model.acquire(lock_identifier) until success
            else
              fail Petra::LockError unless self.class.lock_model.acquire(lock_identifier)
            end

            Petra.logger.debug "Acquired Lock: #{lock_identifier}", :purple
            @held_locks << lock_identifier
            block.call
          ensure
            self.class.lock_model.release(lock_identifier)
            @held_locks.delete(lock_identifier)
            Petra.logger.debug "Released Lock: #{lock_identifier}", :cyan
          end
        end

        #
        # Determines the correct model for Lock entries
        #
        def self.lock_model
          case lock_type.to_s
            when 'index_based'
              Petra::Rails::IndexedLock
            when 'update_based'
              Petra::Rails::Lock
            else
              fail Petra::ConfigurationError, "The lock type '#{lock_type}' is invalid."
          end
        end
      end
    end
  end
end
