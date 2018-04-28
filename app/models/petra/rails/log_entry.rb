# frozen_string_literal: true

module Petra::Rails
  class LogEntry < ActiveRecord::Base
    belongs_to :section, :class_name => 'Petra::Rails::Section'
    serialize :fields, Hash
  end
end
