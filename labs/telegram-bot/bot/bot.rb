require 'telegram/bot'
require 'sinatra'
require 'dotenv/load'
require 'json'

require_relative '../controllers/matrix_controller'

$stdout.sync = true
STDOUT.sync = true

puts "=== Matrix Bot starting on Render (Webhook mode) ==="

TOKEN = ENV['TELEGRAM_BOT_TOKEN']

if TOKEN.nil? || TOKEN.empty?
  puts "ERROR: TELEGRAM_BOT_TOKEN is not set!"
  exit 1
end

puts "TOKEN loaded successfully"

bot = Telegram::Bot::Client.new(TOKEN)

WEBHOOK_URL = "https://#{ENV['RENDER_EXTERNAL_HOSTNAME']}/webhook"

puts "Setting webhook to: #{WEBHOOK_URL}"

begin
  response = bot.api.set_webhook(
    url: WEBHOOK_URL,
    allowed_updates: %w[message callback_query],
    drop_pending_updates: true
  )

  if response['ok'] == true || response == true
    puts "Webhook successfully set to #{WEBHOOK_URL}"
  else
    puts "Failed to set webhook: #{response.inspect}"
  end
rescue => e
  puts "Error while setting webhook: #{e.message}"
  puts e.backtrace.join("\n")
end

#  Sinatra 
set :port, ENV['PORT'] || 10000
set :environment, :production

get '/health' do
  "OK - Matrix Bot is running via webhook"
end

get '/' do
  "Matrix Telegram Bot is alive!<br>Webhook: /webhook"
end

post '/webhook' do
  begin
    update_body = request.body.read
    update = Telegram::Bot::Types::Update.new(JSON.parse(update_body))

    puts "[#{Time.now}] Received update: #{update.class}"

    controller = MatrixController.new(bot)
    controller.handle(update)

    status 200
    body 'OK'
  rescue => e
    puts "[ERROR] #{e.message}"
    puts e.backtrace.join("\n")
    status 200    
    body 'OK'
  end
end

puts "=== Bot started successfully and listening for webhooks ==="
puts "Render hostname: #{ENV['RENDER_EXTERNAL_HOSTNAME']}"