# frozen_string_literal: true

module Relay::Tools
  class RemoveJukeboxEntry < LLM::Tool
    include Relay::Tool

    name "remove-jukebox-entry"
    description "Removes one or more matching tracks from jukebox.yml"
    param :name, String, "The artist or performer name", required: true
    param :title, String, "Optional track title to narrow the match", required: false
    param :url, String, "Optional YouTube URL to narrow the match", required: false

    def call(name:, title: nil, url: nil)
      removed = jukebox.remove(
        name:,
        title: presence(title),
        track: url && jukebox.normalize_track(url)
      )
      if removed.zero?
        {message: "No jukebox entries matched the request", removed: 0}
      else
        {message: "Removed #{removed} jukebox entr#{removed == 1 ? "y" : "ies"}", removed:}
      end
    rescue ArgumentError => ex
      {error: "invalid_entry", message: ex.message}
    rescue => ex
      {error: ex.class.to_s, message: ex.message}
    end

    private

    def jukebox
      @jukebox ||= Relay::Jukebox.new
    end

    def presence(value)
      text = value.to_s.strip
      text.empty? ? nil : text
    end
  end
end
