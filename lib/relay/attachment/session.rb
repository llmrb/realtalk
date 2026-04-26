# frozen_string_literal: true

class Relay::Attachment
  class Session
    require "fileutils"
    require "securerandom"
    require "stringio"

    IMAGE_EXTENSIONS = %w[.png .jpg .jpeg .gif .webp .bmp .tiff .tif .heic .heif].freeze

    ##
    # @param [Hash] session
    # @param [String] root
    # @param [Object, nil] user
    # @param [String, nil] provider
    def initialize(session:, root:, user: nil, provider: nil)
      @session = session
      @root = root
      @user = user
      @provider = provider
    end

    ##
    # @return [Relay::Attachment]
    def file
      @attachment ||= begin
        value = @session["attachment"]
        attachment = Relay::Attachment.new(
          name: value&.[]("name"),
          path: value&.[]("path"),
          type: value&.[]("type")
        )
        clear unless attachment.file?
        attachment
      end
    end

    ##
    # @return [String, nil]
    def error
      @session["attachment_error"]
    end

    ##
    # @param [String] message
    # @return [String]
    def error=(message)
      @session["attachment_error"] = message.to_s
    end

    ##
    # @return [void]
    def clear_error
      @session.delete("attachment_error")
    end

    ##
    # @return [String]
    def accept
      case provider
      when "anthropic" then "image/*,application/pdf,.pdf"
      when "openai", "google" then "*/*"
      else ""
      end
    end

    ##
    # @return [Boolean]
    def supported?
      %w[openai anthropic google].include?(provider)
    end

    ##
    # @param [String] filename
    # @param [String, nil] type
    # @return [Boolean]
    def type_supported?(filename:, type:)
      return false unless supported?
      return image_upload?(filename, type) || pdf_upload?(filename, type) if provider == "anthropic"
      true
    end

    ##
    # @return [String]
    def unsupported_message
      return "#{provider} does not support attachments in Relay yet" unless supported?
      "#{provider} attachments must be images or PDFs"
    end

    ##
    # @param [#read] io
    # @param [String] filename
    # @param [String, nil] type
    # @return [Relay::Attachment]
    def attach(io:, filename:, type:)
      raise ArgumentError, "a file is required" unless io && filename
      FileUtils.mkdir_p(attachments_dir)
      file = Relay::Attachment.new(
        name: sanitize_filename(filename),
        path: File.join(attachments_dir, "#{SecureRandom.hex(8)}-#{sanitize_filename(filename)}"),
        type: type.to_s
      )
      io.rewind if io.respond_to?(:rewind)
      IO.copy_stream(io, file.path)
      @session["attachment"] = file.to_h
      clear_error
      @attachment = file
    end

    ##
    # @return [Relay::Attachment, nil]
    def consume
      value = @session.delete("attachment")
      return unless Hash === value
      @attachment = Relay::Attachment.new(
        name: value["name"],
        path: value["path"],
        type: value["type"]
      )
      @attachment.file? ? @attachment : nil
    end

    ##
    # @return [void]
    def clear
      @session.delete("attachment")
      clear_error
      @attachment = Relay::Attachment.new
    end

    private

    def attachments_dir
      user_id = @user&.id || "anonymous"
      File.join(@root, "tmp", "uploads", user_id.to_s)
    end

    def provider
      @provider || "deepseek"
    end

    def pdf_upload?(filename, type)
      File.extname(filename.to_s).downcase == ".pdf" || type.to_s == "application/pdf"
    end

    def image_upload?(filename, type)
      type.to_s.start_with?("image/") || IMAGE_EXTENSIONS.include?(File.extname(filename.to_s).downcase)
    end

    def sanitize_filename(filename)
      File.basename(filename.to_s).gsub(/[^A-Za-z0-9._-]/, "_")
    end
  end
end
