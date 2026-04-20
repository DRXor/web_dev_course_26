require_relative '../services/matrix_service'
require_relative '../parsers/parser'
require 'telegram/bot'


class MatrixHandler
  @state = {}

  def self.main_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard:[ 
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/add') ,
          Telegram::Bot::Types::KeyboardButton.new(text: '/mul') 
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/sub') ,
          Telegram::Bot::Types::KeyboardButton.new(text: '/det') 
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/inv') ,
          Telegram::Bot::Types::KeyboardButton.new(text: '/transpose') 
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/trace') ,
          Telegram::Bot::Types::KeyboardButton.new(text: '/sym') 
        ]
      ],
      resize_keyboard: true
    )
  end

  def self.call(message, bot)
    text = message.text
    chat_id = message.chat.id

    case text
    when '/start'
      bot.api.send_message(
        chat_id: chat_id,
        text: "Привет! Я бот для работы с матрицами \n\nВыбери операцию:",
        reply_markup: self.main_keyboard
      )

    when '/add'
      @state[chat_id] = :add
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4 | 5,6;7,8")

    when '/mul'
      @state[chat_id] = :mul
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4 | 5,6;7,8")

    when '/det'
      @state[chat_id] = :det
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4")

    when '/sub'
      @state[chat_id] = :sub
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4 | 5,6;7,8")

    when '/inv'
      @state[chat_id] = :inv
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4")

    when '/transpose'
      @state[chat_id] = :transpose
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4")

    when '/trace'
      @state[chat_id] = :trace
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4")

    when '/sym'
      @state[chat_id] = :sym
      bot.api.send_message(chat_id: chat_id, text: "Формат:\n1,2;3,4")

    when /^(.+)\|(.+)$/
      a = parse_matrix($1)
      b = parse_matrix($2)

      mode = @state[chat_id]
      result = 
        case mode
        when :add then MatrixService.add(a, b)
        when :sub then  MatrixService.sub(a, b)
        when :mul then MatrixService.mul(a, b)
        else raise "Не выбрана операция"
        end
      bot.api.send_message(chat_id: chat_id, text: "Результат:\n#{result}")

    when /^[0-9,;\s]+$/
      a = parse_matrix(text)

      mode = @state[chat_id]
      result = 
        case mode
        when :det then MatrixService.det(a)
        when :inv then MatrixService.inv(a)
        when :transpose then MatrixService.transpose(a)
        when :trace then MatrixService.trace(a)
        when :sym then MatrixService.symmetric?(a)
        else 
          raise "Выбери операцию"
        end

        bot.api.send_message(chat_id: chat_id, text: "Результат:\n#{result}")
    end

  rescue => e
    bot.api.send_message(chat_id: message.chat.id, text: "Ошибка: #{e.message}")
  end
end

