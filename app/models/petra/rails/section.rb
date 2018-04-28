# frozen_string_literal: true

module Petra
  module Rails
    class Section < ActiveRecord::Base
      has_many :log_entries,
               class_name: 'Petra::Rails::LogEntry',
               table_name: 'petra_rails_log_entries',
               dependent:  :destroy
    end
  end
end
