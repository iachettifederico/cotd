require_relative "./spec_helper"
require "models/color"


scope do
  let(:date) { Date.new(2012, 12, 28) }
  spec "red" do
    color = Color.new(date)
    color.r == 140
  end

  spec "green" do
    color = Color.new(date)
    color.g == 192
  end

  spec "blue" do
    color = Color.new(date)
    color.b == 44
  end

  spec "code" do
    color = Color.new(date)
    color.code == "8CC02C"
  end

  spec "to_s" do
    color = Color.new(date)
    color.to_s == "#8CC02C"
  end
end

scope do
  let(:code) { "010a33" }

  spec "red" do
    color = Color.for_code(code)
    color.r == 1
  end

  spec "green" do
    color = Color.for_code(code)
    color.g == 10
  end

  spec "blue" do
    color = Color.for_code(code)
    color.b == 51
  end

  spec "date" do
    color = Color.for_code(code)
    color.date.is_a? Date
  end

  spec "code" do
    color = Color.for_code(code)
    color.code == "010A33"
  end


  spec "code" do
    color = Color.for_code(code)
    color.to_s == "#010A33"
  end
end

scope "brightness" do
  test "0" do
    color = Color.for_code("#000000")
    color.brightness == 0
  end

  test "100" do
    color = Color.for_code("#ffffff")
    color.brightness == 100
  end

  test "50" do
    color = Color.for_code("#1F9BFA")
    color.brightness == 50
  end

  test "49" do
    color = Color.for_code("#6F9822")
    color.brightness == 49
  end
end

scope "light and dark" do
  test "0: dark" do
    color = Color.for_code("#000000")
    color.dark
  end

  test "100: light" do
    color = Color.for_code("#ffffff")
    color.light
  end

  test "50: light" do
    color = Color.for_code("#1F9BFA")
    color.light
  end

  test "49: dark" do
    color = Color.for_code("#6F9822")
    color.dark
  end
end
