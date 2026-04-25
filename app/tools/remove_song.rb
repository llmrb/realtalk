# frozen_string_literal: true

module Relay::Tools
  class RemoveSong < LLM::Tool
    include Relay::Tool

    name "remove-song"
    description "Removes one or more matching tracks from jukebox.yml"
    param :by, Enum["name", "title", "url"], "The jukebox field to match against", required: true
    param :value, String, "The artist name, track title, or YouTube URL to remove", required: true

    def call(by:, value:)
      params = remove_params(by, value)
      result = jukebox.remove(**params)
      if result[:removed].zero?
        {
          ok: true,
          by:,
          value:,
          message: "No matching jukebox entries were found; the requested song may already be absent",
          removed: 0,
          entries: []
        }
      else
        {
          ok: true,
          by:,
          value:,
          message: "Removed #{result[:removed]} jukebox entr#{result[:removed] == 1 ? "y" : "ies"}",
          removed: result[:removed],
          entries: result[:entries]
        }
      end
    end

    private

    def jukebox
      @jukebox ||= Relay::Jukebox.new
    end

    def remove_params(by, value)
      text = value.to_s.strip
      raise ArgumentError, "value is required" if text.empty?
      case by
      when "name" then {name: text}
      when "title" then {title: text}
      when "url" then {track: jukebox.normalize_track(text)}
      else raise ArgumentError, "unsupported match field"
      end
    end
  end
end
