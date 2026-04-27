require 'matrix_library'

def parse_matrix(str)
   def self.parse(str)
    raise ArgumentError, "Пустая строка" if str.nil? || str.strip.empty?

    rows = str.strip.split(';').map do |row|
      nums = row.split(',').map(&:strip)

      raise ArgumentError, "Пустая строка" if nums.empty?

      nums.map do |num|
        Float(num)
      rescue
        raise ArgumentError, "Неверное число: #{num}"
      end
    end

    size = rows.first.size
    unless rows.all? { |r| r.size == size }
      raise ArgumentError, "Строки разной длины"
    end

    Matrix.new(rows)
  end
end