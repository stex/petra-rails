module Petra::Rails
  class Lock < ActiveRecord::Base
    def self.acquire(identifier)
      Lock.create(:identifier => identifier)
      true
    rescue
      ActiveRecord::RecordNotUnique
      false
    end

    def self.release(identifier)
      Lock.delete_all(:identifier => identifier)
      true
    end
  end
end
