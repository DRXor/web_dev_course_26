require 'telegram/bot'
require 'sinatra'
require 'dotenv/load'
require 'json'

require_relative '../controllers/matrix_controller'

$stdout.sync = true
STDOUT.sync = true

puts "=== Matrix Bot starting on Render ==="

TOKEN = ENV['TELEGRAM_BOT_TOKEN']

if TOKEN.nil? || TOKEN.empty?
  puts "ERROR: TELEGRAM_BOT_TOKEN is not set!"
  exit 1
end

puts "TOKEN loaded successfully"

bot = Telegram::Bot::Client.new(TOKEN)

WEBHOOK_PATH = "/#{TOKEN}"
WEBHOOK_URL = "https://#{ENV['RENDER_EXTERNAL_HOSTNAME']}#{WEBHOOK_PATH}"

puts "Setting webhook to: #{WEBHOOK_URL}"

begin
  response = bot.api.set_webhook(
    url: WEBHOOK_URL,
    allowed_updates: %w[message callback_query],
    drop_pending_updates: true  
  )

  if response['ok']
    puts "Webhook successfully set!"
  else
    puts "Failed to set webhook: #{response}"
  end
rescue => e
  puts "Error setting webhook: #{e.message}"
  puts e.backtrace
end

#Sinatra приложение

set :port, ENV['PORT'] || 10000
set :environment, :production
set :logging, true

get '/health' do
  content_type :text
  "OK - Matrix Bot is running"
end

get '/' do
  "Matrix Bot is alive! Webhook active."
end

# Основной маршрут для Telegram Webhook
post WEBHOOK_PATH do
  begin
    update_body = request.body.read
    update = Telegram::Bot::Types::Update.new(JSON.parse(update_body))

    puts "Received update: #{update.class} (#{Time.now})"

    controller = MatrixController.new(bot)
    controller.handle(update)

    status 200
    body 'OK'
  rescue => e
    puts "ERROR processing update: #{e.message}"
    puts e.backtrace
    status 200
    body 'OK'
  end
end

puts "=== Bot is ready and listening for webhooks on #{WEBHOOK_URL} ==="
puts "Render external hostname: #{ENV['RENDER_EXTERNAL_HOSTNAME']}"