require 'telegram/bot'
require 'sinatra'
require 'dotenv/load'
require 'json'

require_relative '../controllers/matrix_controller'

TOKEN = ENV['TELEGRAM_BOT_TOKEN']
RENDER_HOST = "https://matrix-telegram-bot-aroi.onrender.com"

puts "=== Matrix Bot starting on Render (Webhook mode) ==="

if TOKEN.nil?
  puts "ERROR: TOKEN not set!"
  puts "Make sure TELEGRAM_BOT_TOKEN is set in Render Environment Variables"
  exit 1
end

puts "TOKEN loaded successfully"

IS_RENDER = ENV['RENDER'] == 'true' || ENV.key?('RENDER')

if IS_RENDER
  puts "=== Running in WEBHOOK mode (Render) ==="
  
  # Set webhook
  bot = Telegram::Bot::Client.new(TOKEN)
  webhook_url = "#{RENDER_HOST}/webhook"
  
  begin
    response = bot.api.set_webhook(url: webhook_url)

    if response == true
      puts "Webhook set successfully"
    else
      puts "Webhook failed: #{response.inspect}"
    end
  rescue => e
    puts "Error while setting webhook: #{e.message}"
    puts e.backtrace
  end
  
  puts "=== Bot started successfully and listening for webhooks ==="
  puts "Render hostname: #{RENDER_HOST.gsub('https://', '')}"
  
  # Sinatra webhook endpoint
  set :port, 3000
  
  post '/webhook' do
    content_type :json
    
    begin
      request.body.rewind
      update_data = JSON.parse(request.body.read)
      
      bot = Telegram::Bot::Client.new(TOKEN)
      
      update = OpenStruct.new(
        message: update_data['message'] ? OpenStruct.new(
          chat: OpenStruct.new(id: update_data['message']['chat']['id']),
          text: update_data['message']['text'],
          from: OpenStruct.new(
            first_name: update_data['message']['from']['first_name'],
            id: update_data['message']['from']['id']
          )
        ) : nil,
        callback_query: update_data['callback_query'] ? OpenStruct.new(
          data: update_data['callback_query']['data'],
          message: OpenStruct.new(
            chat: OpenStruct.new(id: update_data['callback_query']['message']['chat']['id']),
            message_id: update_data['callback_query']['message']['message_id']
          )
        ) : nil
      )
      
      matrix_controller = MatrixController.new(bot)
      matrix_controller.handle(update)
      
      status 200
      body ''
    rescue => e
      puts "Webhook error: #{e.message}"
      puts e.backtrace
      status 200 
      body ''
    end
  end
else
  puts "=== Running in POLLING mode (Local development) ==="
  puts "Bot started. Press Ctrl+C to stop"
  
  bot = Telegram::Bot::Client.new(TOKEN)
  
  bot.listen do |message|
    begin
      puts "Received message from #{message.from.first_name}: #{message.text}"
      
      update = OpenStruct.new(
        message: message,
        callback_query: nil
      )
      
      matrix_controller = MatrixController.new(bot)
      matrix_controller.handle(update)
      
    rescue => e
      puts "Error processing message: #{e.message}"
      puts e.backtrace
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, an error occurred: #{e.message}"
      )
    end
  end
end