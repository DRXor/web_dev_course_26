require_relative '../services/matrix_service'
require_relative '../parsers/parser'
require_relative '../formatters/matrix_formatter'
require_relative '../state/user_state'
require 'telegram/bot'


class MatrixController
  COMMANDS = {
    'add' => :add,
    'sub' => :sub,
    'mul' => :mul,
    'det' => :det,
    'inv' => :inv,
    'transpose' => :transpose,
    'trace' => :trace,
    'sym' => :sym,
  }

  def initialize(bot) 
    @bot = bot
    puts "MatrixController initialized with bot: #{bot ? 'yes' : 'no'}"
  end

  def handle(update)
    puts "Received update: #{update.inspect[0..100]}"
    
    if update.callback_query
      handle_callback(update.callback_query)
    elsif update.message
      handle_message(update.message)
    end
  rescue => e
    puts "Critical error in handle: #{e.message}"
    puts e.backtrace
  end

  private

  def send_message(chat_id, text, keyboard = nil, markdown = false)
    puts "Sending message to #{chat_id}: #{text[0..50]}"
    @bot.api.send_message(
      chat_id: chat_id,
      text: text,
      reply_markup: keyboard,
      parse_mode: (markdown ? 'Markdown' : nil)
    )
  rescue => e
    puts "Failed to send message: #{e.message}"
  end


  def main_keyboard
    Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [btn('Сложение', 'add'), btn('Вычитание', 'sub')],
        [btn('Умножение', 'mul')],
        [btn('Детерминант', 'det'), btn('След', 'trace')],
        [btn('Обратная', 'inv'), btn('Транспонировать', 'transpose')],
        [btn('Симметричность', 'sym')]
      ]
    )
  end

  def back_keyboard
    Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [btn('⬅ Назад', 'back')]
      ]
    )
  end

  def btn(text, data)
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: text,
      callback_data: data
    )
  end

   def format_hint(mode)
    case mode
    when :add, :sub, :mul
      "Введи 2 матрицы:\n1,2;3,4 | 5,6;7,8"
    else
      "Введи матрицу:\n1,2;3,4"
    end
  end

  def send_message(chat_id, text, keyboard = nil, markdown = false)
    @bot.api.send_message(
      chat_id: chat_id,
      text: text,
      reply_markup: keyboard,
      parse_mode: (markdown ? 'Markdown' : nil)
    )
  end

  def edit_message(chat_id, message_id, text, keyboard = nil)
    @bot.api.edit_message_text(
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup: keyboard
    )
  end
end

