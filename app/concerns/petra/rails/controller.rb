# frozen_string_literal: true

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
        # @option options [Symbol, String, Proc] :with_session_key ('petra_transaction_id')
        #   Specifies the session key the current transaction identifier is saved as.
        #   If a symbol is given, a method with the same name has to exist,
        #   If a string is given, it will be used as static session key
        #   If a proc is given, it will receive the current controller instance as argument
        #
        def use_petra_transaction(**options)
          with_session_key = options.delete(:with_session_key) || 'petra_transaction_id'

          around_action options do |controller, action|
            session_key = case with_session_key
                            when Symbol
                              controller.send(with_session_key)
                            when Proc
                              with_session_key.call(controller)
                            else
                              with_session_key.to_sym
                          end
            petra_transaction(session_key, &action)
          end
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
      def petra_transaction(session_key = :petra_transaction_id)
        session[session_key.to_sym] = Petra.transaction(identifier: session[session_key.to_sym]) do
          # Open an inner begin/rescue to catch exception while staying inside of the transaction
          begin
            yield
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
