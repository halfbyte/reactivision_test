#
# A module to easily integrate reactivision tracking
#

require 'osc'


module Reactivision
  class Marker
    attr_reader :symbol, :x, :y, :a, :x_a, :y_a, :a_a
    
    def initialize(symbol)
      @symbol = symbol
      @x, @y, @a, @x_a, @y_a, @a_a = 0,0,0,0,0,0
      @mutex = Mutex.new
    end

    def set(x,y, a, x_a=0, y_a=0, a_a=0)
      @mutex.synchronize do
        @x, @y, @a, @x_a, @y_a, @a_a = x, y, a, x_a, y_a, a_a
      end
    end
  end

  class Cursor
    attr_reader :x, :y
    
    def initialize
      @x, @y = 0,0
      @mutex = Mutex.new
    end

    def set(x,y)
      @mutex.synchronize do
        @x, @y = x, y
      end
    end
  end
  
  
  #
  # Create a new Server which will run in its own thread. server.markers and server.cursors give access to the
  # objects currently on the surface.
  #
  
  class Server
      attr_reader :thread, :markers, :cursors
    def initialize(host = "localhost", port = 3333)
      
      @markers = {}
      @cursors = {}
      @thread = nil
      s = OSC::UDPServer.new
      s.bind host, port
      s.add_method '/tuio/2Dobj', nil do |msg|
        command = msg.args.first        
        if command == 'set'
          command, id, symbol, x, y, a, x_a, y_a, a_a =  msg.args
          if @markers[id].nil?
            @markers[id] = Marker.new(symbol)
          end
          @markers[id].set(x, y, a, x_a, y_a, a_a) 
        elsif command == 'alive'
          command, *alive_ids = msg.args
          @markers.delete_if do |k,v|
            !alive_ids.include?(k)
          end
        end
      end
      s.add_method '/tuio/2Dcur', nil do |msg|
        command = msg.args.first        
        if command == 'set'
          command, id, x, y =  msg.args
          if @cursors[id].nil?
            @cursors[id] = Cursor.new
          end
          @cursors[id].set(x, y) 
        elsif command == 'alive'
          command, *alive_ids = msg.args
          @cursors.delete_if do |k,v|
            !alive_ids.include?(k)
          end
        end
      end


      
      @thread = Thread.new do
        puts "setup server"
        begin
          s.serve
        rescue => e
          puts "tore down: #{e} \n #{e.backtrace}"
        end
      end
      
    end
  end
  
  
  
end