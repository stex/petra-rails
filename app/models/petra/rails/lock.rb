# frozen_string_literal: true

module Petra::Rails
  class Lock < ActiveRecord::Base
    scope :with_identifier, -> (identifier) { where(identifier: identifier) }
    scope :taken, -> { where.not(taken_at: nil) }
    scope :not_taken, -> { where(taken_at: nil) }

    class << self
      def acquire(identifier)
        ensure_lock_existence(identifier)
        affected_rows = not_taken.with_identifier(identifier).update_all(taken_at: Time.now)
        affected_rows > 0
      end

      def release(identifier)
        taken.with_identifier(identifier).update_all(taken_at: nil)
        true
      end

      private

      #
      # Creates a new lock record for the given identifier if it doesn't exist yet
      #
      def ensure_lock_existence(identifier)
        # Please note that the following method is not atomic.
        # There seem to be other ways to perform this insert directly
        # on SQL level, but not all databases provide e.g. a `dual` table
        # (sqlite3 does not for example).
        find_or_create_by(identifier: identifier)
      end
    end

  end
end
