require_relative 'file_parser'
require 'set'
require 'socket'

class Yodeler
  MAX_PACKET_SIZE = 1400
  def self.yodel
    # TODO be smarter about this
    all_files = FileParser.run
    all_files.values.each(&:shuffle!)

    until all_files.to_json.length < MAX_PACKET_SIZE
      all_files[:files].pop
      all_files[:chunks].pop
    end

    packet = all_files.to_json
    write_packet_to_socket(packet)
  end

  def self.write_packet_to_socket(packet)
    sock = UDPSocket.new
    sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    sock.send(packet, 0, '10.1.10.255', 6270)
    sock.close
  end
end

Yodeler.yodel