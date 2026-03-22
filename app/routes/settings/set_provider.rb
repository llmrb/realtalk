# frozen_string_literal: true

module Relay::Routes
  class Settings::SetProvider < Base
    def call
      set_provider
      set_model
      partial("fragments/settings/set_provider", locals:)
    end

    private

    def set_provider
      session["provider"] = params["provider"]
    end

    def set_model
      session["model"] = llm.default_model
    end

    def locals
      {models: cache.models}
    end
  end
end
