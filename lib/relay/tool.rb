# frozen_string_literal: true

module Relay
  module Tool
    ##
    # Returns the root directory of the project
    # @return [String]
    def root
      File.realpath File.join(__dir__, "..", "..")
    end
  end
end
