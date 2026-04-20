require 'telegram/bot'
require_relative 'handlers/matrix_handler'

TOKEN = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    MatrixHandler.call(message, bot)
  end
end

Thread.new do
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: ENV['PORT'] || 3000)
  server.start
end