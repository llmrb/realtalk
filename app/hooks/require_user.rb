# frozen_string_literal: true

module Relay::Hooks
  module RequireUser
    def call
      @user = Relay::Models::User[session["user_id"]]
      @user.nil? ? r.redirect("/sign-in") : super
    end
  end
end
