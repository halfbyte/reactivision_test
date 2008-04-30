$:.unshift('lib')
require 'osc'

Host = 'localhost'
Port = 3333

s = OSC::UDPServer.new
s.bind Host, Port

s.add_method '/tuio/*', nil do |msg|
  domain, port, host, ip = msg.source
  puts "#{msg.address} -> #{msg.args.inspect} from #{host}:#{port}"
end
t = Thread.new do
  puts "b4"
  begin
    s.serve
  rescue => e
    puts "exception: #{e}"
  end
  puts "danach"
end
t.join