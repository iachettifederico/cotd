class Color
  attr_reader :r
  attr_reader :g
  attr_reader :b
  attr_reader :date

  def initialize(date)
    @date = date
    arr = [
      (date.day  * date.month + date.year)  % 256,
      (date.year - date.day   * date.month) % 256,
      (date.day  * date.month * date.year)  % 256,
    ]
    shift = date.day % 3
    shift.times do
      arr.push(arr.shift)
    end

    @r, @g, @b = *arr
  end

  def to_s
    "##{code}"
  end
  
  def code
    @code ||= [to_hex(r), to_hex(g), to_hex(b)].join
  end

  def brightness
    ((0.299*r + 0.587*g + 0.114*b) / 255 * 100).to_i
  end

  def light
    brightness >= 50
  end

  def dark
    ! light
  end

  def self.for_code(code)
    ColorForCode.new(code)
  end
  
  private

  def to_hex(int)
    n = int % 256
    "%02X" % n
  end

  class ColorForCode < Color
    def initialize(code)
      code.gsub!("#", '')
      @date = Date.today
      _, @r, @g, @b = *(code.match(/(\w{2})(\w{2})(\w{2})/).to_a.map {|h|h.to_i(16)})
    end
  end
end
