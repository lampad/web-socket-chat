base = File.dirname(__FILE__)
$:.unshift File.join(base, "lib")

require 'web_socket_chat/server'

run WebSocketChat::Server
