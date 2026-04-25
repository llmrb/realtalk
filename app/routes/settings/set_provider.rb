# frozen_string_literal: true

module Relay::Routes
  class Settings::SetProvider < Base
    prepend Relay::Hooks::RequireUser

    ##
    # Changes the active provider
    # @return [String]
    #  Returns a HTML fragment
    def call
      set_provider
      set_model
      r.redirect("/")
    end

    private

    ##
    # Sets the provider
    # @return [void]
    def set_provider
      session["provider"] = params["provider"]
      session.delete("context_id")
    end

    ##
    # Sets the model
    # @return [void]
    def set_model
      session["model"] = default_model
    end
  end
end
