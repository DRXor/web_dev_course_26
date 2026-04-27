require_relative '../services/matrix_service'
require_relative '../parsers/parser'
require 'telegram/bot'

class MatrixHandler
  @state = {}

  def self.main_keyboard
    Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Сложить", callback_data: "add"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Умножить", callback_data: "mul")
        ],
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Вычесть", callback_data: "sub"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Определитель", callback_data: "det")
        ],
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Обратная", callback_data: "inv"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Транспонировать", callback_data: "transpose")
        ],
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "След", callback_data: "trace"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Симметрична?", callback_data: "sym")
        ]
      ]
    )
  end

  def self.call(message, bot)
    text = message.text
    chat_id = message.chat.id

    case text
    when '/start'
      bot.api.send_message(
        chat_id: chat_id,
        text: "Привет\! Я бот для работы с матрицами.\n\nВыбери операцию:",
        reply_markup: main_keyboard,
        parse_mode: nil
      )

    when '/add', '/mul', '/sub', '/det', '/inv', '/transpose', '/trace', '/sym'
      operation = text[1..-1]
      @state[chat_id] = operation.to_sym

      examples = {
        add:  "1,2;3,4 | 5,6;7,8",
        mul:  "1,2;3,4 | 5,6;7,8",
        sub:  "1,2;3,4 | 5,6;7,8",
        det:  "1,2;3,4",
        inv:  "1,2;3,4",
        transpose: "1,2;3,4",
        trace: "1,2;3,4",
        sym:  "1,2;3,4"
      }

      bot.api.send_message(
        chat_id: chat_id,
        text: "Отправь матрицу(ы) в формате:\n`#{examples[operation.to_sym]}`",
        parse_mode: 'MarkdownV2'
      )

    when /^(.+)\|(.+)$/
      a = parse_matrix($1.strip)
      b = parse_matrix($2.strip)

      mode = @state[chat_id]
      result = case mode
               when :add then MatrixService.add(a, b)
               when :sub then MatrixService.sub(a, b)
               when :mul then MatrixService.mul(a, b)
               else raise "Не выбрана операция"
               end

      send_matrix_result(bot, chat_id, result)

    when /^[0-9,;\s]+$/
      a = parse_matrix(text)

      mode = @state[chat_id]
      result = case mode
               when :det then MatrixService.det(a)
               when :inv then MatrixService.inv(a)
               when :transpose then MatrixService.transpose(a)
               when :trace then MatrixService.trace(a)
               when :sym then MatrixService.symmetric?(a) ? "Да, матрица симметрична" : "Нет, матрица не симметрична"
               else raise "Не выбрана операция"
               end

      send_matrix_result(bot, chat_id, result)

    else
      bot.api.send_message(chat_id: chat_id, text: "Неизвестная команда. Нажми /start")
    end

  rescue => e
    bot.api.send_message(
      chat_id: chat_id,
      text: "Ошибка: #{e.message}",
      parse_mode: nil 
    )
  end

  def self.send_matrix_result(bot, chat_id, result)
    if result.is_a?(Array) || result.is_a?(Matrix) || 
       (result.respond_to?(:to_a) && result.to_a.is_a?(Array))

      matrix_text = format_matrix(result)
      text = "Результат:\n```\n#{matrix_text}\n```"
    else
      text = "Результат:\n```\n#{result}\n```"
    end

    bot.api.send_message(
      chat_id: chat_id,
      text: text,
      parse_mode: 'Markdown'  
    )
  end
  def self.format_matrix(matrix)
    rows = matrix.to_a
    col_widths = rows.transpose.map { |col| col.map(&:to_s).map(&:length).max }

    rows.map do |row|
      row.each_with_index.map do |val, i|
        val.to_s.rjust(col_widths[i])
      end.join("  ")
    end.join("\n")
  end

  def self.handle_callback(callback, bot)
    chat_id = callback.message.chat.id
    data = callback.data   # "add", "mul", "det" и т.д.

    @state[chat_id] = data.to_sym

    examples = {
      add:  "1,2;3,4 | 5,6;7,8",
      mul:  "1,2;3,4 | 5,6;7,8",
      sub:  "1,2;3,4 | 5,6;7,8",
      det:  "1,2;3,4",
      inv:  "1,2;3,4",
      transpose: "1,2;3,4",
      trace: "1,2;3,4",
      sym:  "1,2;3,4"
    }

    bot.api.send_message(
      chat_id: chat_id,
      text: "Выбрана операция: *#{data.upcase}*\n\nОтправь матрицу(ы) в формате:\n`#{examples[data.to_sym]}`",
      parse_mode: 'Markdown'
    )

    # Обязательно отвечаем Telegram, что кнопка обработана
    bot.api.answer_callback_query(callback_query_id: callback.id)
  end
end