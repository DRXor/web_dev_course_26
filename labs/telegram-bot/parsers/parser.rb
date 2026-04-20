def parse_matrix(str)
  raise ArgumentError, "Пустая строка" if str.nil? || str.strip.empty?

  normalized = str.encode("UTF-8", invalid: :replace, undef: :replace)
                  .gsub("\u00A0", " ")
                  .gsub(/\s+/, " ")
                  .strip

  rows = normalized.split(';').map do |row|
    nums = row
       .split(',')
       .reject(&:empty?)
       .map(&:strip) 

    if nums.empty?
      raise ArgumentError, "Пустая строка в матрице"
    end

    nums.map do |num|
      Integer(num)
    rescue ArgumentError
      raise ArgumentError, "Неверное число: #{num.inspect}"
    end
  end

  raise ArgumentError, "Пустая матрица" if rows.empty?

  size = rows.first.size
  
  unless rows.all? { |r| r.size == size }
    raise ArgumentError, "Строки разной длины"
  end

  Matrix.new(rows)
end