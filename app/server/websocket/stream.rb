# frozen_string_literal: true

class Server::Websocket
  class Stream
    def initialize(conn, sock)
      @conn = conn
      @sock = sock
    end

    def <<(chunk)
      @sock.write(@conn, event: "delta", message: chunk.to_s)
    end
  end
end
