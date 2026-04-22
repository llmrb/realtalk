# frozen_string_literal: true

module Relay::Tools
  class AddJukeboxEntry < Base
    name "add-jukebox-entry"
    description "Adds a new track to jukebox.yml from an artist, title, and YouTube link"
    param :name, String, "The artist or performer name", required: true
    param :title, String, "The track title", required: true
    param :url, String, "A YouTube watch/share/embed URL", required: true

    def call(name:, title:, url:)
      entry = JukeboxStore.add(name:, title:, track: url)
      {
        message: "Added jukebox entry",
        entry:
      }
    rescue ArgumentError => ex
      {error: "invalid_entry", message: ex.message}
    rescue => ex
      {error: ex.class.to_s, message: ex.message}
    end
  end
end
