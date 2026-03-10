class Matrix
  attr_reader :rows, :cols, :data

  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @data = Array.new(rows) { Array.new(cols, 0)}
  end

  def [](row, col)
    @data[row][col]
  end

  def []=(row, col, value)
    @data[row][col] = value
  end

  def +(other)
    raise ArgumentError unless compatible?(other)
    result = Matrix.new(@rows, @cols)
    @rows.times do |i|
      @cols.times do |j|
        result[i, j] = @data[i][j] + other[i, j]
      end
    end
    result
  end

  def *(other)
    raise ArgumentError unless @cols == other.rows
    result = Matrix.new(@rows, other.cols)
    @rows.times do |i|
      other.cols.times do |j|
        sum = 0
        @cols.times do |k|
          sum += @data[i][k] * other[k][j]
        end
        result[i, j] = sum
      end
    end
    result
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
    raise ArgumentError unless square?
    return @data[0][0] if @rows == 1
    return @data[0][0] * @data[1][1] - @data[0][1] * @data[1][0] if @rows == 2

    det = 0
    @cols.times do |j|
      det += (@data[0][j] * cofactor(0, j))
    end
    det
  end

  private

  def compatible?(other)
    @rows == other.rows && @cols == other.cols
  end

  def square?
    @rows == @cols
  end

  def minor(i, j)
    Matrix.new(@rows - 1, @cols - 1).tap do |m|
      (@rows - 1).times do |row|
        (@cols - 1).times do |col|
          m[row, col] = @data[row + (row >= i ? 1 : 0)][col + (col >= i ? 1 : 0)]
        end
      end
    end
  end

  def cofactor(i, j)
    (-1) ** (i + j) * minor(i, j).determinant
  end


end