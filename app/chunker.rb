require_relative 'constants'

class Chunker
  class ChunkError < StandardError; end

  def self.get_chunk(file_path, offset)
    f = File.open(file_path)
    byte_offset_idx = offset * CHUNK_SIZE_BYTES

    if f.size < byte_offset_idx
      raise ChunkError.new("File #{f} is too small for chunking")
    end

    f.seek(byte_offset_idx)
    f.read(CHUNK_SIZE_BYTES)
  end
end
