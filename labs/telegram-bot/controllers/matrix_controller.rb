require_relative '../services/matrix_service'
require_relative '../parsers/parser'
require_relative '../formatters/matrix_formatter'
require_relative '../state/user_state'
require 'telegram/bot'


class MatrixController
  COMMANDS = {
    '/add' => :add,
    '/sub' => :sub,
    '/mul' => :mul,
    '/det' => :det,
    '/inv' => :inv,
    '/transpose' => :transpose,
    '/trace' => :trace,
    '/sym' => :sym,
  }

  def initialize(bot) 
    @bot = bot
  end

  def handle(message)
    if update.is_a?(Telegram::Bot::Types::CallbackQuery)
      handle_callback(update)
    else
      handle_message(update)
    end
  end

  private

  def handle_callback(query)
    chat_id = query.message.chat.chat_id
    message_id = query.message.message_id
    data = query.data

    if COMMANDS[data]
      UserState.set(chat_id, COMMANDS[data])

      edit_message(
        chat_id,
        message_id,
        "Выбрана операция: #{data}\n\n#{format_hint(COMMANDS[data])}",
        back_keyboard
      )
    elsif data == 'back'
      UserState.clear(chat_id)

      edit_message(
        chat_id, 
        message_id,
        "Выбери операцию:",
        main_keyboard
      )
    end
  end

  def handle_message(message)
    return unless message.text

    chat_id = message.chat.id
    mode = UserState.get(chat_id)

    if mode.nil?
      send_message(chat_id, "Сначала выбери операцию", main_keyboard)
      return
    end

     if message.text.include?('|')
      a_str, b_str = message.text.split('|', 2)
      result = MatrixService.execute(
        mode,
        MatrixParser.parse(a_str),
        MatrixParser.parse(b_str)
      )
    else
      result = MatrixService.execute(
        mode,
        MatrixParser.parse(message.text)
      )
    end

     send_message(
      chat_id,
      "Результат:\n#{MatrixFormatter.format(result)}",
      main_keyboard,
      true
    )

  rescue ArgumentError => e
    send_message(chat_id, "Ошибка: #{e.message}", back_keyboard)
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

