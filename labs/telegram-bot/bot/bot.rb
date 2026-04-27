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
    
    if response['ok']
      puts "Webhook set successfully: #{response['description']}"
    else
      puts "Webhook response: #{response.inspect}"
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
      update = JSON.parse(request.body.read)
      
      bot = Telegram::Bot::Client.new(TOKEN)
      
      if update['message']
        chat_id = update['message']['chat']['id']
        text = update['message']['text']
        
        puts "Received message: #{text} from #{chat_id}"
        
        matrix_controller = MatrixController.new
        response_text = matrix_controller.process(text)
        
        response_text = "Echo: #{text}"
        
        bot.api.send_message(
          chat_id: chat_id,
          text: response_text
        )
      end
      
      status 200
      body ''
    rescue => e
      puts "Webhook error: #{e.message}"
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
      
      matrix_controller = MatrixController.new
      response_text = matrix_controller.process(message.text)
      
      response_text = "Echo: #{message.text}"
      
      bot.api.send_message(
        chat_id: message.chat.id,
        text: response_text
      )
    rescue => e
      puts "Error processing message: #{e.message}"
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, an error occurred: #{e.message}"
      )
    end
  end
end