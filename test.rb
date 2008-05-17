require 'rubygems'
$:.unshift('lib')

require 'gosu'
require 'reactivision'

include  Gosu

SCREEN_WIDTH=800
SCREEN_HEIGHT=600

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

class GameWindow < Window
  attr_accessor :marker
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 16)
    self.caption = "Gosutaxi"
    @x = 0
    @y = 0
    @background_image = Image.new(self, 'media/background.png', true)
    @marker = Image.new(self, 'media/point.png', true)
    @cursor = Image.new(self, 'media/cursor.png', true)
    @ra_server = Reactivision::Server.new
    @font = Font.new(self,"Monaco", 20)
  end
  def draw
    #@background_image.draw(0,0,0)
    
    @ra_server.markers.each do |id, marker|
      @marker.draw_rot(marker.x * SCREEN_WIDTH, marker.y * SCREEN_HEIGHT, 1, (marker.a + (Math::PI / 2)).radians_to_gosu )
      @font.draw("#{marker.symbol}", marker.x* SCREEN_WIDTH, marker.y * SCREEN_HEIGHT, 2, 1.0, 1.0, 0xff0000ff)
    end
    
    @ra_server.cursors.each do |id, cursor|
      @cursor.draw_rot(cursor.x * SCREEN_WIDTH, cursor.y * SCREEN_HEIGHT, 2, 0)
    end
    
    
    #@marker.draw if @marker
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
window.show
