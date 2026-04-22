# frozen_string_literal: true

module Relay::Routes
  class Settings::SetModel < Base
    prepend Relay::Hooks::RequireUser

    def call
      set_model
      r.redirect("/")
    end

    private

    def set_model
      session["model"] = params["model"]
      session.delete("context_id")
    end
  end
end
