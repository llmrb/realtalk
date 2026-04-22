# frozen_string_literal: true

module Relay::Pages
  ##
  # Renders the chat page.
  class Chat < Base
    prepend Relay::Hooks::RequireUser

    ##
    # @return [String]
    def call
      response["content-type"] = "text/html"
      session["provider"] ||= "deepseek"
      session["model"] ||= "deepseek-chat"
      page("chat", title: "Relay", messages: ctx.messages, models: chat_models, contexts:)
    end
  end
end
