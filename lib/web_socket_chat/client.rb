require 'faye/websocket'
require 'eventmachine'

module WebSocketChat
  class Client

    def initialize(url, chatroom, user)
      @url = url
      @chatroom = chatroom
      @user = user
      @server_listen_thread = start_listen_thread
      @client_loop = start_client_loop
    end

    def start_client_loop
      loop do
        input = gets.chomp
        if input == "quit"
          @ws.send "QUIT,#{@user},#{@chatroom}"
        else
          @ws.send "CHAT,#{@user},#{@chatroom}:#{input}"
        end
      end
    end

    def start_listen_thread
      Thread.new do
        EM.run {
          @ws = Faye::WebSocket::Client.new(@url)
          @ws.on :open do |event|
            p [:open]
            @ws.send("CONNECT,#{@user},#{@chatroom}")
          end

          @ws.on :message do |event|
            p [:message, event.data]
          end

          @ws.on :close do |event|
            p [:close, event.code, event.reason]
            ws = nil
            exit
          end
        }
      end
    end
  end
end
