# frozen_string_literal: true

require "fileutils"
require "securerandom"
require "stringio"

module Relay::Concerns
  module Attachment
    IMAGE_EXTENSIONS = %w[.png .jpg .jpeg .gif .webp .bmp .tiff .tif .heic .heif].freeze

    def pending_attachment
      value = session["pending_attachment"]
      return unless Hash === value
      path = value["path"]
      return unless path && File.file?(path)
      value
    end

    def pending_attachment_error
      session["pending_attachment_error"]
    end

    def clear_pending_attachment_error
      session.delete("pending_attachment_error")
    end

    def attachment_accept
      case attachment_provider
      when "anthropic" then "image/*,application/pdf,.pdf"
      when "openai", "google" then "*/*"
      else ""
      end
    end

    def attach_file(io:, filename:, type:)
      raise ArgumentError, "a file is required" unless io && filename
      FileUtils.mkdir_p(attachments_dir)
      name = sanitize_filename(filename)
      path = File.join(attachments_dir, "#{SecureRandom.hex(8)}-#{name}")
      io.rewind if io.respond_to?(:rewind)
      IO.copy_stream(io, path)
      session["pending_attachment"] = {"name" => name, "path" => path, "type" => type.to_s}
      clear_pending_attachment_error
      pending_attachment
    end

    def consume_pending_attachment
      session.delete("pending_attachment")
    end

    def clear_pending_attachment
      session.delete("pending_attachment")
      clear_pending_attachment_error
    end

    def attachment_provider_supported?
      %w[openai anthropic google].include?(attachment_provider)
    end

    def attachment_type_supported?(filename:, type:)
      return false unless attachment_provider_supported?
      return image_upload?(filename, type) || pdf_upload?(filename, type) if attachment_provider == "anthropic"
      true
    end

    def unsupported_attachment_message
      return "#{attachment_provider} does not support attachments in Relay yet" unless attachment_provider_supported?
      "#{attachment_provider} attachments must be images or PDFs"
    end

    private

    def attachment_provider
      session["provider"] || "deepseek"
    end

    def attachments_dir
      user_id = respond_to?(:user) && user ? user.id : "anonymous"
      File.join(Relay.root, "tmp", "uploads", user_id.to_s)
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
