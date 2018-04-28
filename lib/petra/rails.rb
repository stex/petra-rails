# frozen_string_literal: true

require 'petra/rails/engine'
require 'petra/rails/persistence_adapters/active_record_adapter'

require 'petra/proxies/active_record_proxy'
require 'petra/proxies/active_record_relation_proxy'

require 'petra/rails/util/rescue_handlers'

module Petra
  module Rails
  end
end

# Register Persistence Adapters
Petra::PersistenceAdapters::Adapter.register_adapter :active_record,
                                                     Petra::Rails::PersistenceAdapters::ActiveRecordAdapter
