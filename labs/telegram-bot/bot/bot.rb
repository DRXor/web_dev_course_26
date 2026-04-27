require 'telegram/bot'
require_relative '../controllers/matrix_controller'
require 'webrick'
require 'dotenv/load'

$LOAD_PATH << File.expand_path('../matrix_library/lib', __dir__)
$LOAD_PATH << File.expand_path('..', __dir__)

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
controller = MatrixController.new(nil)

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |update|
    begin
      controller.handle(update)
    rescue => e
      puts "ERROR: #{e.message}"
    end
  end
end