require "net/http"
require "optparse"

class YumlCmd
  
  def YumlCmd.generate(args)
    ext = "png"
    input = output = nil
    type = "/scruffy"
    opts = OptionParser.new do |o|
      o.banner = "Usage: #{File.basename($0)} [options]"
      o.on('-f', '--file FILENAME', 'File containing yuml.me diagram.') do |filename|
        input = filename
      end        
      o.on('-t', '--type EXTENSION', 'Output format: png (default), jpg') do |extension|
        ext = extension if extension
      end
      o.on('-o', '--orderly', 'Generate orderly') do |type|
        type = "" if type
      end      
      o.on('-n', '--name OUTPUT', 'Output filename') do |name|
        output = name
      end          
      o.on_tail('-h', '--help', 'Display this help and exit') do
        puts opts
        exit
      end              
    end
    opts.parse!(args)

    lines = IO.readlines(input).collect!{|l| l.gsub("\n", "")}.reject{|l| l =~ /#/}
    output = output || "#{input.gsub(".", "-")}"
    writer = open("#{output}.#{ext}", "wb")

    res = Net::HTTP.start("yuml.me", 80) {|http|
      http.get(URI.escape("/diagram#{type}/class/#{lines.join(",")}"))
    }
    writer.write(res.body)
    writer.close
  end
  
end

if $0 == __FILE__
  YumlCmd.generate(ARGV)
end