require 'rspec'
require_relative '../app/ranter'

describe Ranter do
  let(:kanye_sha) { "u6y3TEU7R+WxAux+iJBG6+XE8YDFSQNW2RMXgpCxie4=" }
  let(:random_sha) { "8OTC92xYkW7CWPJGhRvqCR0U1CR6L8PhhpRGGxgW4Ts=" }
  let(:kanye_chunk) { 'this is a kanye chunk' }
  let(:random_chunk) { 'this is a random chunk '}
  let(:local_metadata) do
    {
      "files" => [
        {
          "sha" => kanye_sha,
          "size" => 10_000_000,
          "name" => "kanye.mp3"
        }
      ],
      "chunks" => [
        {
          "sha" => random_sha,
          "offset" => 3
        }
      ]
    }
  end
  let(:addr) { '1.2.3.4' }

  before(:each) do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('../local_metadata.json').
      and_return(local_metadata.to_json)
    allow(File).to receive(:read).
      with("../chunks/#{random_sha}:chunk:3").and_return(random_chunk)
  end

  describe '.respond_to_plead' do
    subject { described_class.respond_to_plead(packet, addr) }

    context 'when chunk can be found' do
      context 'requesting a chunk' do
        let(:packet) { { sha: random_sha, offset: 3 }.to_json }

        it "finds the right chunk and writes to network" do
          expect(Network).to receive(:write_to_tcp_socket).
            with(addr, 1.chr + random_chunk)
          subject
        end
      end

      context 'requesting a file' do
        let(:packet) { { sha: kanye_sha, offset: 20 }.to_json }

        it "calls the Chunker and writes to network" do
          allow(Chunker).to receive(:get_chunk).with('../share/kanye.mp3', 20).
            and_return(kanye_chunk)

          expect(Network).to receive(:write_to_tcp_socket).
            with(addr, 1.chr + kanye_chunk)
          subject
        end
      end
    end

    context 'when chunk cannot be found' do
      let(:packet) { { sha: 'not a real sha', offset: 3 }.to_json }

      it "writes a 0 byte to the network" do
        expect(Network).to receive(:write_to_tcp_socket).
          with(addr, 0.chr)
        subject
      end
    end
  end
end
