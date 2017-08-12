# -*- coding: utf-8 -*-

lib = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rpi/i2cbus"
require "rpi/bme280"

require "date"

i2cbus = RPi::I2CBus.new(1)
bme = RPi::BME280.new(i2cbus)

bme.update

puts DateTime.now.strftime('%F %T')
puts "Temperature: #{bme.temperature} ºC"
puts "Pressure: #{bme.pressure} mb"
puts "Humidity: #{bme.humidity} %"
