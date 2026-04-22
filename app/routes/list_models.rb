# frozen_string_literal: true

module Relay::Routes
  class ListModels < Base
    prepend Relay::Hooks::RequireUser

    ##
    # Returns the chat-capable models for the provider
    # @return [Array]
    def call
      partial("fragments/models", {locals:})
    end

    private

    def locals
      {models: chat_models}
    end
  end
end
