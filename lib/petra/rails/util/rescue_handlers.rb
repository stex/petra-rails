# frozen_string_literal: true

module Petra
  module Rails
    module Util
      class RescueHandlers

        class << self
          def for_controller(controller)
            @instances                  ||= {}
            @instances[controller.to_s] ||= new(controller)
          end
        end

        #
        # Registers a new rescue handler for the given exception class
        #
        # @param [Class < Petra::PetraError] petra_error
        #   The error class to be rescued from
        #
        # @param [String, Symbol] with
        #   If given, the system will assume that an instance method with this name exists
        #   in the given controller class or one of its superclasses.
        #   Otherwise, a block has to be given.
        #
        # @param [Array<String, Symbol>] only
        #   Only exceptions raised in the given actions are handled
        #
        # @param [Array<String, Symbol>] except
        #   Only exceptions that were NOT raised in the given actions are handled
        #
        def register(petra_error, with: nil, only: [], except: [], &block)
          fail ArgumentError, 'Either a method name or a proc has to be given' unless with || block_given?

          hash          = {error_class: petra_error.to_s}
          hash[:proc]   = block if block_given?
          hash[:method] = with&.to_sym
          hash[:only]   = Array(only).map(&:to_sym)
          hash[:except] = Array(except).map(&:to_sym)

          handlers << hash
        end

        #
        # Searches for a registered petra rescue handler.
        # Like `rescue_from`, it will automatically search for registered handlers in
        # the controllers superclasses
        #
        # @param [Petra::PetraError] exception
        #   The actual exception to be handled
        #
        # @param [ActionController::Base] controller_instance
        #   The currently executed controller instance
        #
        # @param [String, Symbol] action_name
        #   The currently executed action
        #
        # TODO: Like rescue_from, exception class hierarchies correctly, most specific first
        #
        def exception_handler(exception, controller_instance, action_name:)
          return nil if klass == ActionController::Base

          handler = handlers.find do |h|
            next false unless h[:error_class] == exception.class.to_s
            next false if h[:only].any? && !h[:only].include?(action_name.to_sym)
            !h[:except].include?(action_name.to_sym)
          end

          return handler[:proc] || controller_instance.method(handler[:method]) if handler

          superklass_handlers.exception_handler(exception, controller_instance, action_name: action_name)
        end

        #
        # @return [Boolean] +true+ if there is a registered handler for the given exception
        #   in the current controller class or one of its superclasses.
        #
        # @see #exception_handler for more information
        #
        def exception_handler?(*args)
          !!exception_handler(*args)
        end

        #
        # Searches for a handler for the given exception and executes it
        #
        # @see #exception_handler for more information
        #
        def handle(exception, *args)
          handler = exception_handler(exception, *args)
          raise exception unless handler
          handler.call(exception)
        end

        private

        def initialize(controller_class)
          @controller_class = controller_class.to_s
          @controller_superclass = controller_class.superclass.to_s
        end

        def handlers
          @handlers ||= []
        end

        def klass
          @controller_class.constantize
        end

        def superklass
          @controller_superclass.constantize
        end

        def superklass_handlers
          self.class.for_controller(superklass)
        end
      end
    end
  end
end
