require 'json'
require 'digest'

class FileParser
  def self.run
    json = {files: [], chunks: []}
    each_file('share') do |file|
      json[:files] << {
        sha: Digest::SHA2.base64digest(file.read),
        size: file.size,
        name: File.basename(file.path)
      }
    end

    each_file('chunks') do |chunk|
      name = File.basename(chunk.path)
      sha, _, offset = name.split(':')
      json[:chunks] << {
        sha: sha,
        offset: offset.to_i
      }
    end

    json_string = json.to_json
    File.open('local_metadata.json', 'w') do |f|
      f.write(json.to_json)
    end

    json
  end

  def self.each_file(folder_name)
    Dir.foreach(folder_name) do |filename|
      next if filename == '.' or filename == '..'

      yield File.open("#{folder_name}/#{filename}")
    end
  end
end