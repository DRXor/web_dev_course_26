require '../matrix_library/lib/matrix_library.rb'

class MatrixService
  def self.execute(mode, a, b = nil)
    case mode
    when :add then add(a, b)
    when :sub then sub(a, b)
    when :mul then mul(a, b)
    when :det then a.det
    when :inv then a.inverse
    when :transpose then a.transpose
    when :trace then a.trace
    when :sym then a.symmetric?
    else 
      raise ArgumentError, "Операция не выбрана"
    end
  end

  def self.add(a, b)
    validate_same_size(a, b)
    a + b
  end

   def self.sub(a, b)
    validate_same_size(a, b)
    a - b
  end

  def self.mul(a, b)
    raise ArgumentError, "Несовместимые размеры" unless a.cols == b.rows
    a * b
  end

  private

  def self.validate_same_size(a, b)
    unless a.rows == b.rows && a.cols == b.cols
      raise ArgumentError, "Размеры не совпадают"
    end
  end
end