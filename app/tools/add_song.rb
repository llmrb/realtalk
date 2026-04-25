# frozen_string_literal: true

module Relay::Tools
  class AddSong < LLM::Tool
    include Relay::Tool

    name "add-song"
    description "Adds a new track to jukebox.yml from an artist, title, and YouTube link"
    param :name, String, "The artist or performer name", required: true
    param :title, String, "The track title", required: true
    param :url, String, "A YouTube watch/share/embed URL", required: true

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
