require 'json'
require 'digest'

class FileParser
  def self.run
    parsed = { files: [], chunks: [] }
    each_file(dir: '../share') do |file|
      parsed[:files] << {
        sha: Digest::SHA2.base64digest(file.read),
        size: file.size,
        name: File.basename(file.path)
      }
    end

    each_file(dir: '../chunks') do |chunk|
      name = File.basename(chunk.path)
      sha, _, offset = name.split(':')
      parsed[:chunks] << {
        sha: sha,
        offset: offset.to_i
      }
    end

    File.write(LOCAL_METADATA_PATH, parsed.to_json)
    parsed
  end

  def self.each_file(dir:)
    Dir.foreach(dir) do |filename|
      next if filename == '.' or filename == '..'

      yield File.open("#{dir}/#{filename}")
    end
  end
end
