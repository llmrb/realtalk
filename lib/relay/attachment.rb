# frozen_string_literal: true

class Relay::Attachment
  require_relative "attachment/session"

  ##
  # @param [Hash] session
  # @param [String] root
  # @param [Object, nil] user
  # @param [String, nil] provider
  # @return [Relay::Attachment::Session]
  def self.session(session:, root:, user: nil, provider: nil)
    Session.new(session:, root:, user:, provider:)
  end

  ##
  # @param [String, nil] name
  # @param [String, nil] path
  # @param [String, nil] type
  def initialize(name: nil, path: nil, type: nil)
    @name = name.to_s
    @path = path.to_s
    @type = type.to_s
  end

  ##
  # @return [String]
  attr_reader :name

  ##
  # @return [String]
  attr_reader :path

  ##
  # @return [String]
  attr_reader :type

  ##
  # @return [Boolean]
  def file?
    !path.empty? && File.file?(path)
  end

  ##
  # @return [Boolean]
  def attached?
    file?
  end

  ##
  # @return [Hash<String, String>]
  def to_h
    {"name" => name, "path" => path, "type" => type}
  end
end
