require 'faye/websocket'
Faye::WebSocket.load_adapter('thin')

module WebSocketChat
  @@room_to_users = {}
  Server = lambda do |env|
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      ws.on :message do |event|
        p [:message, event.data]
        case event.data.chomp
        when /QUIT/
          cmd,user,room = event.data.chomp.split(',')
          @@room_to_users[room].each {|sock| sock.send("#{user} has left #{room}")} if @@room_to_users[room]
          ws.close(1000, "client disconnect")
        when /CONNECT/
          cmd,user,room = event.data.chomp.split(',')
          @@room_to_users[room] ||= []
          @@room_to_users[room].each {|sock| sock.send("#{user} joined the room.")}
          @@room_to_users[room] << ws
          ws.send("Welcome to #{room}, #{user}!")
        when /CHAT/
          header,content = event.data.chomp.split(":")
          cmd,user,room = header.split(",")
          @@room_to_users[room].each {|sock| sock.send("#{user}: #{content}")} if @@room_to_users[room]
        else
          ws.send(event.data)
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      # Normal HTTP request
      [200, {'Content-Type' => 'text/plain'}, ['Hello']]
    end
  end
end
