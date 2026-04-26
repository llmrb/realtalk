# frozen_string_literal: true

module Relay::Concerns
  ##
  # Shared Roda integration for Relay page and route base classes.
  #
  # This concern stores the current Roda instance, exposes the request
  # object as `r`, and delegates unknown helper calls back to Roda so
  # pages and routes can use methods like `view`, `partial`, `session`,
  # `request`, and `response` without re-defining that plumbing.
  module Roda
    ##
    # @param [Roda] roda
    # @return [void]
    def initialize(roda)
      @roda = roda
    end

    ##
    # @return [Roda::RodaRequest]
    #  Alias the request object as `r` to match Roda route blocks.
    def r
      @roda.request
    end

    ##
    # Delegates missing methods to the current Roda instance.
    # @param [Symbol] name
    # @param [Array] args
    # @param [Hash] kwargs
    # @return [Object]
    def method_missing(name, *args, **kwargs, &block)
      if @roda.respond_to?(name)
        @roda.send(name, *args, **kwargs, &block)
      else
        super
      end
    end

    ##
    # Returns true when the current Roda instance can respond to a
    # delegated method.
    # @param [Symbol] name
    # @param [Boolean] include_private
    # @return [Boolean]
    def respond_to_missing?(name, include_private = false)
      @roda.respond_to?(name) || super
    end
  end
end
