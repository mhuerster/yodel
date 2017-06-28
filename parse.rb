require "json"
require "socket"

YODEL_HOST = "10.1.10.255"
YODEL_PORT = 6250

@recipient = UDPSocket.new
@recipient.bind(YODEL_HOST, YODEL_PORT)

def listen
  puts "Listening on host #{YODEL_HOST} and port #{YODEL_PORT}..."
  data, addr = @recipient.recvfrom(1024)
  source_ip = addr[3]
  parse(data, source_ip)
end

def known_files_on_disk
  @known_files ||= JSON.parse(IO.read("d.json")).fetch("discovered_files", [])
end

def parse(data, source_ip)
  puts "Data received: #{data} from IP #{source_ip}"
  data_hash = JSON.parse(data)
  files = data_hash["files"]
  chunks = data_hash["chunks"]
  known_files = known_files_on_disk


  files.each do |f|
    binding.pry
    if known_files.find { |kf| kf["sha1"] == f["sha"] }
      kf["locations"].push({"ip" => source_ip, "filename" => f["name"]})
      # TODO - make sure this is saved
    else
      known_files.push({
        "sha1" => f["sha"],
        "size" => f["size"],
        "locations" => [{ "ip" => source_ip, "filename" => f["name"]}]
      })
    end

    #f = File.new("d",  "w+")
    #f.write(known_files)
    p known_files
  end

  chunks.each do |c|
  end
end

while true do
  listen
end
