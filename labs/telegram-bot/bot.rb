require 'telegram/bot'
require_relative 'handlers/matrix_handler'
require 'webrick'

Thread.new do
  server = WEBrick::HTTPServer.new(
    Port: ENV['PORT'] || 10000,
    Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
    AccessLog: []
  )

  server.mount_proc '/' do |req, res|
    res.body = "OK"
  end

  server.start
end


TOKEN = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    if message.is_a?(Telegram::Bot::Types::CallbackQuery)
      # Нажали на inline-кнопку
      MatrixHandler.handle_callback(message, bot)
    else
      # Обычное текстовое сообщение
      MatrixHandler.call(message, bot)
    end
  end
end

Thread.new do
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: ENV['PORT'] || 3000)
  server.start
end