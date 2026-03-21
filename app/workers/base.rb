# frozen_string_literal: true

module Relay
  module Workers
    class Base
      include Sidekiq::Worker
    end
  end
end
