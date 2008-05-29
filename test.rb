require 'rubygems'
$:.unshift('lib')

require 'gosu'
require 'reactivision'

include  Gosu

SCREEN_WIDTH=1024
SCREEN_HEIGHT=768

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
    super(SCREEN_WIDTH, SCREEN_HEIGHT, true, 16)
    self.caption = "reacTIVision TestApp"
    @x = 0
    @y = 0
    @background_image = Image.new(self, 'media/background.png', true)
    @marker = Image.new(self, 'media/point.png', true)
    @marker_red = Image.new(self, 'media/point_red.png', true)
    @marker_green = Image.new(self, 'media/point_green.png', true)
    @marker_blue = Image.new(self, 'media/point_blue.png', true)
    @cursor = Image.new(self, 'media/cursor.png', true)
    @ra_server = Reactivision::Server.new
    @font = Font.new(self,"Monaco", 20)
  end
  def draw
    
    red, green, blue = 0,0,0
    
    @ra_server.markers.each do |id, marker|
      red = (marker.a / (3.14 *2)) * 0xFF if marker.symbol == 3
      green = (marker.a / (3.14 *2)) * 0xFF if marker.symbol == 6
      blue = (marker.a / (3.14 *2)) * 0xFF if marker.symbol == 14          
    end
    color = (red.to_i << 16) + (green.to_i << 8) + blue.to_i + 0xff000000
    
    
    #@background_image.draw(0,0,0)
    
    @ra_server.markers.each do |id, marker|
      
      image = case(marker.symbol)
      when 3: @marker_red
      when 6: @marker_green
      when 14: @marker_blue
      else
        @marker
      end
      
      image.draw_rot(SCREEN_WIDTH - (marker.x * SCREEN_WIDTH), marker.y * SCREEN_HEIGHT, 1, ((Math::PI / 2) - (marker.a + (Math::PI / 2))).radians_to_gosu )
      @font.draw("#{marker.symbol}", SCREEN_WIDTH - (marker.x* SCREEN_WIDTH), marker.y * SCREEN_HEIGHT, 2, 1.0, 1.0, 0xffff00ff)
      @ra_server.markers.each do |id_i, marker_i|
        self.draw_line( SCREEN_WIDTH - (marker.x * SCREEN_WIDTH), marker.y * SCREEN_HEIGHT, color,
                        SCREEN_WIDTH - (marker_i.x * SCREEN_WIDTH), marker_i.y * SCREEN_HEIGHT, color,
                        3)
      end
    end
    
    @ra_server.cursors.each do |id, cursor|
      @cursor.draw_rot(SCREEN_WIDTH - (cursor.x * SCREEN_WIDTH), cursor.y * SCREEN_HEIGHT, 2, 0)
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
