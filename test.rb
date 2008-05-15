require 'rubygems'
$:.unshift('lib')
require 'gosu'
require 'osc'

include  OSC
include  Gosu
PORT = 3333
SCREEN_WIDTH=640
SCREEN_HEIGHT=480

# mutex = Mutex.new

$objects = {}
$object = nil

class Numeric
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end
  
  def radians_to_gosu
    self * 180.0 / Math::PI + 90
  end
  
  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end


class Marker
  def initialize(window)
    @x, @y, @a = 0,0,0
    @image = Image.new(window, 'media/point.png', true)
    @mutex = Mutex.new
  end
  
  def set(x,y, a)
    @mutex.synchronize do
      @x = x * SCREEN_WIDTH
      @y = y * SCREEN_HEIGHT
      @a = a
    end
  end
  
  def draw
    @mutex.synchronize do
      @image.draw_rot(@x, @y, 1, (@a + (Math::PI / 2)).radians_to_gosu )
    end
  end
  
end

class GameWindow < Window
  attr_accessor :marker
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 16)
    self.caption = "Gosutaxi"
    @x = 0
    @y = 0
    @background_image = Image.new(self, 'media/background.png', true)
  end
  def draw
    @background_image.draw(0,0,0)
    @marker.draw if @marker
  end
  
  def button_down(id)
    case id
    when Gosu::Button::KbEscape
      close
    end
  end

  def update
    Thread.pass
  end
  
end

window = GameWindow.new
marker = Marker.new(window)
window.marker = marker

s = OSC::UDPServer.new
s.bind 'localhost', 3333


s.add_method '/tuio/2Dobj', nil do |msg|
  
  if msg.args[0].to_s == 'set' && msg.args[2].to_i == 0
    # puts "#{msg.inspect}"
    marker.set(msg.args[3].to_f, msg.args[4].to_f, msg.args[5]) 
  end 
end

Thread.new do
  puts "setup server"
  begin
    s.serve
  rescue
    puts "tore down"
  end
end
window.show
# th.join
