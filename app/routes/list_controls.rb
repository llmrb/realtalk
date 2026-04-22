# frozen_string_literal: true

module Relay::Routes
  class ListControls < Base
    prepend Relay::Hooks::RequireUser

    def call
      partial("fragments/controls", locals:)
    end

    private

    def locals
      {models: chat_models, contexts:}
    end
  end
end
