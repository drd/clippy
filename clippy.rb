# /usr/local/bin/macruby
#
# clippy.rb
#
# Created by Eric O'Connell on 2/10/09.
# Copyright Roundpeg Designs, 2009
#

# username = exec("security find-generic-password -gs Twitterrific | grep acct")
# puts "username: #{username.split('"').last.inspect}"
# exit

framework 'Cocoa'
require 'net/http'
require 'yaml'

# raise YAML.load(File.read('acct.yaml')).inspect

# thank you: http://trac-git.assembla.com/breakout/browser/lib/trac2assembla.rb#L517

class MultipartPost
  BOUNDARY = 'tarsiers-rule0000'
  HEADER = {"Content-type" => "multipart/form-data, boundary=" + BOUNDARY + " "}

  def prepare_query (params)
    fp = []
    params.each {|k,v|
      if v.respond_to?(:read)
        fp.push(FileParam.new(k, v.path, v.read))
      else
        fp.push(Param.new(k,v))
      end
    }
    query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
    return query, HEADER
  end
end

class Param
  attr_accessor :k, :v
  def initialize( k, v )
    @k = k
    @v = v
  end

  def to_multipart
    #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    # Don't escape mine...
    return "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
  end
end

class FileParam
  attr_accessor :k, :filename, :content
  def initialize( k, filename, content )
    @k = k
    @filename = filename
    @content = content
  end

  def to_multipart
    #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: image/png\r\n\r\n" + content + "\r\n "
    # Don't escape mine
    return "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: image/png\r\n\r\n" + content + "\r\n"
  end
end

pb = NSPasteboard.generalPasteboard()

data = pb.dataForType(pb.types.first).writeToFile('/tmp/twitpic.tiff', atomically:true)

`sips -s format png /tmp/twitpic.tiff --out /tmp/twitpic.png`

pic = File.open('/tmp/twitpic.png')

# find username and password

query, headers = MultipartPost.new.prepare_query(
  YAML.load(File.read('acct.yaml')).merge(
	'media' => pic,
	'message' => ARGV[0]
))

request = Net::HTTP::Post.new('/api/uploadAndPost', headers)
request.body = query

# puts query

http = Net::HTTP.new('twitpic.com', 80)

response = http.request(request)