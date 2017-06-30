require 'rspec'
require_relative '../app/chunker'

describe Chunker do
  let(:valid_file) { 'valid_file' }
  let(:short_file) { 'short_file' }
  before(:each) do
    stub_const('CHUNK_SIZE_BYTES', 6)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(valid_file).
      and_return(StringIO.new('01234567890123456789'))
    allow(File).to receive(:open).with(short_file).
      and_return(StringIO.new('0123'))
  end

  describe '.get_chunk' do
    it 'returns the right 0th chunk for a valid file' do
      expect(Chunker.get_chunk(valid_file, 0)).to eq('012345')
    end

    it 'returns the right 1st chunk for a valid file' do
      expect(Chunker.get_chunk(valid_file, 1)).to eq('678901')
    end

    it 'returns the right final chunk for a valid file' do
      expect(Chunker.get_chunk(valid_file, 3)).to eq('89')
    end

    it 'correctly reads a short file' do
      expect(Chunker.get_chunk(short_file, 0)).to eq('0123')
    end

    it 'raises an error given an invalid chunk' do
      expect { Chunker.get_chunk(valid_file, 200) }.to raise_error(Chunker::ChunkError)
    end
  end
end
