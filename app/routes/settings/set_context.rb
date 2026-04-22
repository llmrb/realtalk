# frozen_string_literal: true

module Relay::Routes
  class Settings::SetContext < Base
    prepend Relay::Hooks::RequireUser

    def call
      set_context
      r.redirect("/")
    end

    private

    def set_context
      sync_context!(selected_context) if selected_context
    end

    def selected_context
      @selected_context ||= Relay::Models::Context.where(user_id: user.id, provider:, id: params["context_id"]).first
    end
  end
end
