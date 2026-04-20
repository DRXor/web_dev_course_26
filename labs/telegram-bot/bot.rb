require 'telegram/bot'
require_relative 'handlers/matrix_handler'

TOKEN = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    MatrixHandler.call(message, bot)
  end
end