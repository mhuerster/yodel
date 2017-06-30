require_relative 'constants'
require_relative 'chunker'
require_relative 'network'
require 'json'

class Ranter
  def self.respond_to_plead(packet, addr)
    request = JSON.parse(packet)
    sha = request['sha']
    offset = Integer(request['offset'])

    chunk = find_chunk(sha, offset)
    if chunk.nil?
      response = 0.chr
    else
      response = chunk.prepend(1.chr)
    end

    Network.write_to_tcp_socket(addr, response)
  end

  def self.find_chunk(sha, offset)
    our_files = JSON.parse(File.read(LOCAL_METADATA_PATH))
    files, chunks = our_files.values_at('files', 'chunks')
    matching_chunk = chunks.find do |chunk|
      chunk['sha'] == sha && Integer(chunk['offset']) == offset
    end
    matching_file = files.find { |file| file['sha'] == sha }

    if matching_file
      puts "File found: #{matching_file}"
      Chunker.get_chunk("../share/#{matching_file['name']}", offset)
    elsif matching_chunk
      puts "Chunk found: #{matching_chunk}"
      filename = [sha, 'chunk', offset].join(':')
      File.read("../chunks/#{filename}")
    else
      nil
    end
  end
end
