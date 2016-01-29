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
        # @param [Hash] options
        #   See ActionController::Base#around_action
        #
        def use_petra_transaction(**options)
          around_action :petra_transaction, options
        end

        #
        # Registers a rescue handler for the given petra exception class
        #
        # @see Petra::Rails::Util::RescueHandlers#register for more details
        #
        def petra_rescue_from(petra_error, **options, &block)
          Petra::Rails::Util::RescueHandlers.for_controller(self).register(petra_error, **options, &block)
        end
      end

      #
      # Runs the given block within a petra transaction section
      # It automatically saves the current identifier in the session and will
      # continue the transaction with the next call.
      #
      # TODO: Add a kind of retry-mechanism, so multiple exceptions might be handled in one action, e.g. multiple ReadIntegrityErrors.
      #    It works as it is, but it might take several redirects.
      #
      def petra_transaction(&block)
        ::Petra.transaction(identifier: session[:transaction_id]) do
          # Open an inner begin/rescue to catch exception while staying inside of the transaction
          begin
            block.call
          rescue Petra::PetraError, ActionView::Template::Error => e
            handle_petra_exception(e)
          end
        end
      end

      private

      #
      # Tries to handle the given exception using previously registered rescue handlers
      # If no valid handler could be found, the exception is re-raised.
      #
      def handle_petra_exception(e)
        # Unwrap action_view template errors
        return handle_petra_exception(e.original_exception) if e.is_a?(ActionView::Template::Error)

        # Try to find a handler for the given exception and execute it
        Petra::Rails::Util::RescueHandlers.for_controller(self.class).handle(e, self, action_name: action_name)
      end
    end
  end
end
