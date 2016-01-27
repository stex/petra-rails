module Petra
  module Rails
    module Controller

      extend ActiveSupport::Concern

      included do
        extend ClassMethods
      end

      module ClassMethods
        #
        # Helper method to generate an around action to wrap even template
        # rendering into a petra transaction section
        #
        def use_petra_transaction(**options)
          around_action :petra_transaction, options
        end
      end

      def petra_transaction(&block)
        if session[:transaction_id]
          ::Petra.transaction(identifier: session[:transaction_id], &block)
        else
          session[:transaction_id] = Petra.transaction(&block)
        end
      end

    end
  end
end
