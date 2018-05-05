# frozen_string_literal: true

module Petra
  module Proxies
    class ActiveRecordRelationProxy < Petra::Proxies::ObjectProxy

      CLASS_NAMES = %w[ActiveRecord::Relation].freeze
      include Enumerable
      include Petra::Proxies::EnumerableProxy::InstanceMethods

      delegate :each, to: :to_a

      #
      # Method which is called e.g. by Model/Relation.all.
      # It returns the original collection, but adds all objects of the same type
      # which were created during the current transaction to the array.
      #
      # TODO: This is definitely not a good solution, but it works for demonstration purposes.
      #   It doesn't check neither conditions nor ordering and cannot determine
      #   the context it is run in, e.g. that there might be single table inheritance classes
      #   of the proxied class which would have to appear in the result set as well.
      #
      def to_a
        collection = Petra::Proxies::EnumerableProxy.proxy_entries(__handlers.handle_missing_method(:to_a))
        collection += transaction.objects.created(proxied_object.klass)
        collection.reject(&:__destroyed?)
      end

      # Same behaviour as in the original ActiveRecord::Relation to ensure
      # that the correct #to_a is called.
      delegate :to_ary, to: :to_a
    end
  end
end
