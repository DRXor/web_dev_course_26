require 'telegram/bot'
require_relative '../controllers/matrix_controller'
require 'webrick'
require 'dotenv/load'

$LOAD_PATH << File.expand_path('../matrix_library/lib', __dir__)
$LOAD_PATH << File.expand_path('..', __dir__)

$stdout.sync = true
puts "=== Starting bot ==="

# Запускаем WEBrick сервер для Render health checks
server_thread = Thread.new do
  begin
    server = WEBrick::HTTPServer.new(
      Port: ENV['PORT']&.to_i || 10000,
      Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
      AccessLog: []
    )

    server.mount_proc '/' do |req, res|
      res.status = 200
      res.body = "Bot is running!"
    end

    server.mount_proc '/health' do |req, res|
      res.status = 200
      res.body = "OK"
    end

    trap('TERM') { server.shutdown }
    trap('INT') { server.shutdown }
    
    server.start
    puts "WEBrick server started on port #{ENV['PORT'] || 10000}"
  rescue => e
    puts "WEBrick error: #{e.message}"
  end
end

sleep 2

TOKEN = ENV['TELEGRAM_BOT_TOKEN']

if TOKEN.nil? || TOKEN.empty?
  puts "ERROR: TELEGRAM_BOT_TOKEN is not set!"
  exit 1
end

puts "Token found: #{TOKEN[0..10]}..."

# Запускаем бота с правильной инициализацией контроллера
begin
  Telegram::Bot::Client.run(TOKEN) do |bot|
    puts "Bot client created successfully"
    
    # Передаем bot в контроллер, а не nil!
    controller = MatrixController.new(bot)
    puts "MatrixController initialized with bot"
    
    bot.listen do |update|
      begin
        controller.handle(update)
      rescue => e
        puts "ERROR in handle: #{e.message}"
        puts e.backtrace
      end
    end
  end
rescue => e
  puts "FATAL ERROR: #{e.message}"
  puts e.backtrace
  exit 1
end

server_thread.join