require 'telegram/bot'
require 'sinatra'
require 'dotenv/load'
require 'json'

require_relative '../controllers/matrix_controller'

TOKEN = ENV['TOKEN']
RENDER_HOST = "https://matrix-telegram-bot-aroi.onrender.com"

puts "=== Matrix Bot starting on Render (Webhook mode) ==="

if TOKEN.nil?
  puts "ERROR: TOKEN not set!"
  exit 1
end

puts "TOKEN loaded successfully"

# Set webhook
bot = Telegram::Bot::Client.new(TOKEN)
webhook_url = "#{RENDER_HOST}/webhook"

begin
  response = bot.set_webhook(url: webhook_url)
  
  if response == true
    puts "Webhook set successfully"
  else
    puts "Webhook response: #{response.inspect}"
  end
rescue => e
  puts "Error while setting webhook: #{e.message}"
end

puts "=== Bot started successfully and listening for webhooks ==="
puts "Render hostname: #{RENDER_HOST.gsub('https://', '')}"

set :port, 3000

post '/webhook' do
  request.body.rewind
  update = JSON.parse(request.body.read)
  
  bot = Telegram::Bot::Client.new(TOKEN)
  
  if update['message']
    chat_id = update['message']['chat']['id']
    text = update['message']['text']
    
    bot.api.send_message(
      chat_id: chat_id,
      text: "Echo: #{text}"
    )
  end
  
  status 200
  body ''
end