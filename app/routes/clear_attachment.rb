# frozen_string_literal: true

module Relay::Routes
  class ClearAttachment < Base
    prepend Relay::Hooks::RequireUser

    def call
      clear_pending_attachment
      response["content-type"] = "text/html"
      partial("fragments/input")
    end
  end
end
