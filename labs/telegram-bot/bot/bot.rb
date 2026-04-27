require 'telegram/bot'
require_relative '../controllers/matrix_controller'
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
  controller = MatrixController.new(bot)

  bot.listen do |update|
    controller.handle(update)
  end
end

Thread.new do
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: ENV['PORT'] || 3000)
  server.start
end