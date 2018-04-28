# frozen_string_literal: true

module Petra
  module Rails
    class IndexedLock < ActiveRecord::Base

      class << self
        def acquire(identifier)
          create(identifier: identifier)
          true
        rescue ActiveRecord::RecordNotUnique
          false
        end

        def release(identifier)
          delete_all(identifier: identifier)
          true
        end
      end
    end
  end
end
