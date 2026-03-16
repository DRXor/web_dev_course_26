class Matrix
  attr_reader :rows, :cols, :data

  def initialize(rows, cols = nil)
    if rows.is_a?(Array) && cols.nil?
      #конструктор из двумерного массива
      @data = rows.map { |row| row.dup }
      @rows = @data.size
      @cols = @data.first&.size || 0
    else
      @rows = rows
      @cols = cols
      @data = Array.new(rows) { Array.new(cols, 0) }
    end
  end

  #создание единичной матрицы
  def self.identity(n)
    matrix = new(n, n)
    n.times { |i| matrix[i, i] = 1 }
    matrix
  end

  #создание матрицы из массива
  def self.[](*rows)
    new(rows)
  end



  def [](row, col)
    @data[row][col]
  end

  def []=(row, col, value)
    @data[row][col] = value
  end


  def row(i)
    @data[i].dup
  end

  def col(j)
    @rows.times.map { |i| @data[i][j] }
  end



  def +(other)
    raise ArgumentError, "Матрицы должны быть одного размера" unless compatible?(other)
    result = Matrix.new(@rows, @cols)
    @rows.times do |i|
      @cols.times do |j|
        result[i, j] = @data[i][j] + other[i, j]
      end
    end
    result
  end

  def -(other)
    raise ArgumentError, "Матрицы должны быть одного размера" unless compatible?(other)
    result = Matrix.new(@rows, @cols)
    @rows.times do |i|
      @cols.times do |j|
        result[i, j] = @data[i][j] - other[i, j]
      end
    end
    result
  end

  def *(other)
    if other.is_a?(Numeric)
      result = Matrix.new(@rows, @cols)
      @rows.times do |i|
        @cols.times do |j|
          result[i, j] = @data[i][j] * other
        end
      end
      result
    elsif other.is_a?(Matrix)
      raise ArgumentError, "Несовместимые размеры для умножения" unless @cols == other.rows
      result = Matrix.new(@rows, other.cols)
      @rows.times do |i|
        other.cols.times do |j|
          sum = 0
          @cols.times do |k|
            sum += @data[i][k] * other[k, j]
          end
          result[i, j] = sum
        end
      end
      result
    else
      raise ArgumentError, "Неверный тип операнда"
    end
  end

  def /(other)
    case other
    when Numeric
      self * (1.0 / other)
    when Matrix
      self * other.inverse #правое деление 
    end
  end

  def left_divide(other)
    self.inverse * other
  end



  def transpose
    result = Matrix.new(@cols, @rows)
    @rows.times do |i|
      @cols.times do |j|
        result[j, i] = @data[i][j]
      end
    end
    result
  end

  def determinant
    raise ArgumentError, "Матрица должна быть квадратной" unless square?
    
    case @rows
    when 1
      @data[0][0]
    when 2
      @data[0][0] * @data[1][1] - @data[0][1] * @data[1][0]
    else
      det = 0
      @cols.times do |j|
        det += @data[0][j] * cofactor(0, j)
      end
      det
    end
  end
  alias_method :det, :determinant


  def minor(i, j)
    minor_data = []
    @rows.times do |row|
      next if row == i
      minor_row = []
      @cols.times do |col|
        next if col == j
        minor_row << @data[row][col]
      end
      minor_data << minor_row
    end
    Matrix.new(minor_data)
  end

  def cofactor(i, j)
    (-1) ** (i + j) * minor(i, j).determinant
  end


  #обратная матрица
  def inverse
    raise ArgumentError, "Матрица должна быть квадратной" unless square?
    det = determinant
    raise ArgumentError, "Матрица вырождена (det = 0)" if det == 0

    if @rows == 1
      return Matrix.new([[1.0 / @data[0][0]]])
    end

    result = Matrix.new(@rows, @cols)
    @rows.times do |i|
      @cols.times do |j|
        result[j, i] = cofactor(i, j) / det.to_f
      end
    end
    result
  end


  def square?
    @rows == @cols
  end

  def symmetric?
    return false unless square?
    @rows.times do |i|
      @cols.times do |j|
        return false if @data[i][j] != @data[j][i]
      end
    end
    true
  end

  def trace
    raise ArgumentError, "Матрица должна быть квадратной" unless square?
    sum = 0
    @rows.times { |i| sum += @data[i][i] }
    sum
  end

  def to_s
    @data.map { |row| row.join("\t")}.join("\n")
  end

  def ==(other)
    return false unless other.is_a?(Matrix) && @rows == other.rows && @cols == other.cols
    
    @rows.times do |i|
      @cols.times do |j|
        return false if @data[i][j] != other[i, j]
      end
    end
    true
  end

   private

  def compatible?(other)
    @rows == other.rows && @cols == other.cols
  end

end