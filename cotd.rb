require "cuba"
require "cuba/render"
require "time"

def ordinalize(int)
  if (11..13).include?(int % 100)
    "#{int}th"
  else
    case int % 10
    when 1; "#{int}st"
    when 2; "#{int}nd"
    when 3; "#{int}rd"
    else    "#{int}th"
    end
  end
end

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
  def permalink_for(date)
    "#{req.env["rack.url_scheme"]}://#{req.env["HTTP_HOST"]}/#{date.year}/#{date.month}/#{date.day}"
  end

  def page_not_found
    res.status = 404
    res.headers["Content-Type"] = "text/html; charset=utf-8"
    res.write view("shared/404")
  end

  def style_for(code)
    template = open("views/templates/style.scss").read % {code: code}

    IO.popen("sass -s --compass --scss --trace", "w+") do |pipe|
      pipe.puts template
      pipe.close_write
      pipe.read
    end
  end

  self.define do
    on root do
      date = Date.today
      code = code_for(date)

      res.write view("index", code: code, date: date)
    end

    on ":y/:m/:d" do |year, month, day|
      date = Date.new(year.to_i, month.to_i, day.to_i)
      code = code_for(date)

      res.write view("index", code: code, date: date)
    end

    on "codes" do
      # codes = (1..10).map { ([hex_rand, hex_rand, hex_rand]).join }
      num = 1000
      codes = 1.upto(num).each_with_object({}) do |i, h|
        date = Date.today + i - (num/2)
        code = code_for(date)
        h[date] = code
      end

      res.write view("codes", codes: codes)
    end

    on "style" do
      begin
        code = code_for(Date.today)

        res.write style_for(code)
      rescue Exception => e
        res.write e.stack_trace
      end
    end

    on "force_code/:code" do |code|
      res.write view("index", code: code, date: Date.today)
    end
    
    on default do
      page_not_found
    end
  end
end
