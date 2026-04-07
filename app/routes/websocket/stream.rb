# frozen_string_literal: true

class Relay::Routes::Websocket
  class Stream < LLM::Stream
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
    def on_content(chunk)
      @sock.stream(@conn, chunk.to_s)
    end

    ##
    # On tool call
    # @return [void]
    def on_tool_call(tool, error)
      @sock.report_tool_status(@conn, tool)
      queue << (error || tool.spawn(:task))
    end
  end
end
