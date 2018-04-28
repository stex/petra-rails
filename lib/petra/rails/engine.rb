# frozen_string_literal: true

module Petra
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Petra::Rails
    end
  end
end
