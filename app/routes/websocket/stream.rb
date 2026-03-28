# frozen_string_literal: true

class Relay::Routes::Websocket
  class Stream
    ##
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [Relay::Routes::Websocket] sock
    #  The websocket route object
    def initialize(conn, sock)
      @conn = conn
      @sock = sock
    end

    ##
    # Writes a streamed text chunk
    # @param [String] chunk
    #  The streamed text chunk
    # @return [void]
    def <<(chunk)
      @sock.stream(@conn, chunk.to_s)
    end
  end
end
