# -*- coding: utf-8 -*-

lib = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rpi/i2cbus"
require "rpi/bme280"
require "time"

# slackの設定
WEBHOCKURL = "<slack-incoming-webhock-url>"
CHANNEL = "#general"

# BME280に接続
i2cbus = RPi::I2CBus.new(1)
bme = RPi::BME280.new(i2cbus)

# センサーからの値を更新
bme.update

require 'slack-notifier'

# slackに通知
attachment = {
  color: "good",
  pretext: "#{Time.now().strftime('%F %T')}の気温: #{bme.temperature} ℃",
  fields: [
    {
      title: "気温",
      value: "#{bme.temperature} ℃",
      short: true,
    },
    {
      title: "湿度",
      value: "#{bme.humidity} %",
      short: true,
    },
    {
      title: "気圧",
      value: "#{bme.pressure} hPa",
      short: true,
    },
  ],
  ts: Time.now.to_i,
}

attachment[:color] = 'danger' if bme.temperature > 35;
attachment[:color] = 'warning' if bme.temperature > 30;

notifier = Slack::Notifier.new WEBHOCKURL,
                               channel: CHANNEL,
                               username: '気温湿度計'
notifier.ping '', attachments: [ attachment ], icon_emoji: ":thermometer:"
