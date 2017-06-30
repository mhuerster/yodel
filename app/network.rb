require_relative 'constants'
require 'socket'

class Network
  def self.write_to_tcp_socket(addr, message)
    socket = TCPSocket.new(addr, YODEL_PORT)
    socket.write(message)
    socket.close
  end

  def self.write_packet_to_udp_socket(packet)
    socket = UDPSocket.new
    socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    socket.send(packet, 0, '10.1.10.255', YODEL_PORT)
    socket.close
  end
end
