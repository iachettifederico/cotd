require "cuba"
require "cuba/render"
require "time"

Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = "haml"

def hex_rand
  n = rand(256)
  "%02X" % n
end

def to_hex(int)
  n = int % 256
  "%02X" % n
end

def code_for(date)
  arr = [
    to_hex(date.day * date.month + date.year),
    to_hex(date.year - date.day * date.month),
    to_hex(date.day * date.month * date.year),
  ]
  shift = date.day % 3
  shift.times do
    arr.push(arr.shift)
  end
  arr.join
end

class Cuba
  def page_not_found
    res.status = 404
    res.headers["Content-Type"] = "text/html; charset=utf-8"
    res.write view("shared/404")
  end

  self.define do
    on root do
      date = Date.today
      code = code_for(date)

      res.write view("index", code: code, date: date)
    end

    on "codes" do
      # codes = (1..10).map { ([hex_rand, hex_rand, hex_rand]).join }
      codes = 1.upto(10).each_with_object({}) do |i, h|
        date = Date.today + i
        code = code_for(date)
        h[date] = code
      end

      res.write view("codes", codes: codes)
    end

    on default do
      page_not_found
    end
  end
end