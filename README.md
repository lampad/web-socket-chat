# web-socket-chat

A simple chat client and server using web sockets for communication

## Usage:

`gem install bundler`

`bundle install`

Start the server:

`thin start -R config.ru`

Connect to the server:

`bundle exec bin/client`

You'll want to enter the address of the websocket ('ws://127.0.0.1:3000' by default)