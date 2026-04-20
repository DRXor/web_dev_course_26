require 'telegram/bot'
require_relative 'handlers/matrix_handler'

TOKEN = '8745581870:AAFRAkArBGb1khLNAuSd2TiMu137ff6uhWk'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    MatrixHandler.call(message, bot)
  end
end