require 'gosu'

def media_path(file)
  File.join(File.dirname(File.dirname(__FILE__)), 'media', file)
end

# Explosion class
class Explosion
  FRAME_DELAY = 10 # ms
  SPRITE = media_path('explosion.png')

  def self.load_animation(window)
    Gosu::Image.load_tiles(
      window, SPRITE, 128, 128, false
    )
  end

  def initialize(animation, x, y)
    @animation = animation
    @x = x
    @y = y
    @current_frame = 0
  end

  # TODO: because it's frime_expired always truly it's seems like this always add+1
  def update
    @current_frame += 1 if frame_expired?
  end

  # TODO: Take a look it dose not returns true, it returns nill
  def draw
    return if done?
    image = current_frame
    image.draw(
      @x - image.width / 2.0,
      @y - image.height / 2.0,
      0
    )
  end

  def done?
    @done ||= @current_frame == @animation.size
  end

  private

  def current_frame
    @animation[@current_frame % @animation.size]
  end

  # TODO: this looks interestng too, this frame_expried? alway return true.
  def frame_expired?
    now = Gosu.milliseconds
    @last_frame ||= now
    return @last_frame = now if (now - @last_frame) > FRAME_DELAY
  end
end

# Game winodw
class GameWindow < Gosu::Window
  BACKGROUND = media_path('country_field.png')
  def initialize(width = 800, height = 600, fullscreen = false)
    super
    self.caption = 'Hello Animation'
    @background = Gosu::Image.new(
      BACKGROUND
    )
    @animation = Explosion.load_animation(self)
    @explosion = []
  end

  # TODO: Looks like reject!(&:done?) dose not do aniting
  def update
    @explosion.reject!(&:done?)
    @explosion.map(&:update)
  end

  def button_down(id)
    close if Gosu::KbEscape == id
    return unless Gosu::MsLeft == id
    @explosion.push(Explosion.new(@animation, mouse_x, mouse_y))
  end

  def needs_cursor?
    true
  end

  def needs_redraw?
    !@scence_ready || @explosion.any?
  end

  def draw
    @scence_ready ||= true
    @background.draw(0, 0, 0)
    @explosion.map(&:draw)
  end
end

window = GameWindow.new
window.show
