
require "cuba"
require "cuba/render"
require "time"

require "susy"
require "breakpoint"

require "./models/color"

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
      color = Color.new(date)

      res.write view("index", color: color)
    end

    on "date", param(:day), param(:month), param(:year) do |day, month, year|
      path = [year, month, day].join("/")
      res.redirect "/" + path
    end

    on ":y/:m/:d" do |year, month, day|
      begin
        date = Date.new(year.to_i, month.to_i, day.to_i)
        color = Color.new(date)

        res.write view("index", color: color)
      rescue ArgumentError => e
        res.redirect "/"
      end
    end

    on "codes" do
      num = 1000
      colors = 1.upto(num).map { |i|
        date = Date.today + i - (num/2)
        Color.new(date)
      }

      res.write view("codes", colors: colors)
    end

    on "brightness" do
      num = 1000
      colors = 1.upto(num).map { |i|
        date = Date.today + i - (num/2)
        Color.new(date)
      }.sort_by(&:brightness)

      res.write view("codes", colors: colors)
    end

    on "style" do
      begin
        code = Color.new(Date.today).code

        res.write style_for(code)
      rescue Exception => e
        res.write e.backtrace.join("<br>")
      end
    end

    on "force_code/:code" do |code|
      res.write view("index", color: Color.force_code(code))
    end

    on default do
      page_not_found
    end
  end
end
