# frozen_string_literal: true

module Relay::Tools
  class AddSong < LLM::Tool
    include Relay::Tool

    name "add-song"
    description "Adds a new track from an artist, title, and YouTube link"
    parameter :name, String, "The artist or performer name"
    parameter :title, String, "The track title"
    parameter :url, String, "A YouTube watch/share/embed URL"
    required %i[name title url]

    def call(name:, title:, url:)
      entry = jukebox.add(name:, title:, track: url)
      {
        message: "Added jukebox entry",
        entry:
      }
    end

    private

    def jukebox
      @jukebox ||= Relay::Jukebox.new
    end
  end
end
