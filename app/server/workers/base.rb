# frozen_string_literal: true

module Server
  module Workers
    class Base
      include Sidekiq::Worker
    end
  end
end
