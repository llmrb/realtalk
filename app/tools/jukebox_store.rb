# frozen_string_literal: true

require "cgi"
require "uri"
require "yaml"

module Relay::Tools
  module JukeboxStore
    module_function

    def path
      File.join(Relay.resources_dir, "jukebox.yml")
    end

    def load
      YAML.safe_load_file(path, permitted_classes: [], aliases: false) || []
    end

    def save(entries)
      File.write(path, YAML.dump(entries))
    end

    def normalize_track(url)
      uri = URI.parse(url.to_s.strip)
      host = uri.host.to_s.downcase

      video_id =
        case host
        when "youtu.be"
          uri.path.split("/").reject(&:empty?).first
        when "youtube.com", "www.youtube.com", "m.youtube.com",
             "youtube-nocookie.com", "www.youtube-nocookie.com"
          extract_youtube_id(uri)
        end

      raise ArgumentError, "unsupported YouTube URL" if video_id.to_s.empty?

      "https://www.youtube-nocookie.com/embed/#{video_id}"
    rescue URI::InvalidURIError
      raise ArgumentError, "invalid YouTube URL"
    end

    def remove(name:, title: nil, track: nil)
      entries = load
      before = entries.length
      entries.reject! do |entry|
        next false unless entry["name"].to_s == name.to_s
        next false if title && entry["title"].to_s != title.to_s
        next false if track && entry["track"].to_s != track.to_s

        true
      end
      save(entries) if entries.length != before
      before - entries.length
    end

    def add(name:, title:, track:)
      entries = load
      normalized_track = normalize_track(track)
      entry = {"name" => name.to_s.strip, "title" => title.to_s.strip, "track" => normalized_track}
      raise ArgumentError, "name is required" if entry["name"].empty?
      raise ArgumentError, "title is required" if entry["title"].empty?

      entries << entry
      save(entries)
      entry
    end

    def extract_youtube_id(uri)
      path = uri.path.to_s
      return path.split("/").reject(&:empty?).last if path.start_with?("/embed/", "/shorts/")

      CGI.parse(uri.query.to_s).fetch("v", []).first
    end
  end
end
