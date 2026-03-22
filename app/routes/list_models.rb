# frozen_string_literal: true

module Relay::Routes
  class ListModels < Base
    ##
    # Returns the chat-capable models for the provider
    # @return [Array]
    def call
      cache.models = filter(llm.models.all)
      partial("fragments/models", {locals:})
    end

    private

    def locals
      {models: cache.models}
    end

    def filter(models)
      models.select(&:chat?)
    end
  end
end
