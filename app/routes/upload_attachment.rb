# frozen_string_literal: true

require "cgi"

module Relay::Routes
  class UploadAttachment < Base
    prepend Relay::Hooks::RequireUser

    def call
      raise ArgumentError, attachment.unsupported_message unless attachment.type_supported?(filename:, type:)
      attachment.attach(io: request.body, filename:, type:)
      response.status = 200
      response["content-type"] = "text/html"
      partial("fragments/input")
    rescue ArgumentError => e
      attachment.error = e.message
      response.status = 422
      response["content-type"] = "text/html"
      partial("fragments/input")
    end

    private

    def filename
      value = request.get_header("HTTP_X_FILE_NAME").to_s
      value = CGI.unescape(value)
      raise ArgumentError, "a file is required" if value.empty?
      value
    end

    def type
      request.get_header("CONTENT_TYPE")
    end
  end
end
