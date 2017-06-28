require 'socket'

YODEL_HOST = "10.1.10.255"
YODEL_PORT = 6250

recipient = UDPSocket.new
recipient.bind(YODEL_HOST, YODEL_PORT)
