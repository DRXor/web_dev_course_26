require 'telegram/bot'
require_relative '../controllers/matrix_controller'
require 'webrick'
require 'dotenv/load'

$LOAD_PATH << File.expand_path('../matrix_library/lib', __dir__)
$LOAD_PATH << File.expand_path('..', __dir__)

# Принудительный вывод логов
$stdout.sync = true
STDOUT.sync = true

puts "=== Starting bot ==="
puts "Step 1: Loading dependencies completed"

# Запускаем WEBrick сервер
puts "Step 2: Starting WEBrick server..."
server_thread = Thread.new do
  begin
    puts "Step 2.1: Creating WEBrick server on port #{ENV['PORT']&.to_i || 10000}"
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

    puts "Step 2.2: Starting WEBrick server"
    server.start
  rescue => e
    puts "WEBrick error: #{e.message}"
    puts e.backtrace
  end
end

sleep 2
puts "Step 3: WEBrick server thread started"

TOKEN = ENV['TELEGRAM_BOT_TOKEN']
puts "Step 4: TOKEN = #{TOKEN ? 'PRESENT' : 'MISSING'}"
puts "Step 4.1: TOKEN value: #{TOKEN[0..10]}..." if TOKEN

if TOKEN.nil? || TOKEN.empty?
  puts "ERROR: TELEGRAM_BOT_TOKEN is not set!"
  exit 1
end

puts "Step 5: Attempting to start Telegram bot..."

begin
  puts "Step 5.1: Calling Telegram::Bot::Client.run"
  Telegram::Bot::Client.run(TOKEN) do |bot|
    puts "Step 6: Bot client created successfully"
    
    puts "Step 7: Creating MatrixController with bot"
    controller = MatrixController.new(bot)
    puts "Step 8: MatrixController initialized"
    
    puts "Step 9: Bot is now listening for updates..."
    puts "=== Bot is ready and waiting for messages ==="
    
    bot.listen do |update|
      begin
        puts "Received update: #{update.class}"
        controller.handle(update)
      rescue => e
        puts "ERROR in handle: #{e.message}"
        puts e.backtrace
      end
    end
  end
rescue => e
  puts "FATAL ERROR in bot initialization: #{e.message}"
  puts e.backtrace
  exit 1
end

puts "This line should not be reached"
server_thread.join