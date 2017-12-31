# -*- coding: utf-8 -*-

lib = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rpi/i2cbus"
require "rpi/bme280"
require "time"

# slackの設定
WEBHOCKURL = "<slack-incoming-webhock-url>"
CHANNEL = "#general"

# slackにpostする閾値
THRESHOLD_HOT = 30;             # この温度を越えたら
THRESHOLD_COLD = 10;            # この温度を下回ったら

# BME280に接続
i2cbus = RPi::I2CBus.new(1)
bme = RPi::BME280.new(i2cbus)

# センサーからの値を更新
bme.update

if bme.temperature <= THRESHOLD_HOT && bme.temperature >= THRESHOLD_COLD
  # 高温閾値より低い and 低温閾値より高い
  exit
end

require 'slack-notifier'

# slackに通知
attachment = {
  color: "good",
  text: "#{Time.now().strftime('%F %T')}の気温: #{bme.temperature} ℃",
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

# 暑い場合
attachment[:color] = 'warning' if bme.temperature > 30;
attachment[:color] = 'danger' if bme.temperature > 35;

# 寒い場合
attachment[:color] = '#33ccff' if bme.temperature < 20;
attachment[:color] = '#3333ff' if bme.temperature < 10;
attachment[:color] = '#3300ff' if bme.temperature < 0;

if bme.temperature <= THRESHOLD_COLD
  attachment[:text] += "\n低温閾値(#{THRESHOLD_COLD}℃)を下回りました。"
end

if bme.temperature >= THRESHOLD_HOT
  attachment[:text] += "\n高温閾値(#{THRESHOLD_COLD}℃)を上回りました。"
end

notifier = Slack::Notifier.new WEBHOCKURL,
                               channel: CHANNEL,
                               username: '気温湿度計'
notifier.ping '', attachments: [ attachment ], icon_emoji: ":thermometer:"
