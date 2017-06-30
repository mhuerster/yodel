require_relative 'file_parser'
require_relative 'constants'
require_relative 'network'
require 'set'

class Yodeler
  def self.yodel
    FileParser.run unless File.exists?(LOCAL_METADATA_PATH)

    all_files = JSON.load(File.read(LOCAL_METADATA_PATH))
    all_files.values.each(&:shuffle!)

    until all_files.to_json.length < MAX_UDP_PACKET_SIZE
      all_files['files'].pop
      all_files['chunks'].pop
    end

    packet = all_files.to_json
    Network.write_packet_to_udp_socket(packet)
  end
end
