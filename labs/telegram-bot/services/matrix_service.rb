require 'matrix_library'

class MatrixService
  def self.add(a, b)
    a + b
  end

  def self.sub(a, b)
    a - b
  end

  def self.mul(a, b)
    a * b
  end

  def self.det(a)
    a.det
  end

  def self.trace(a)
    a.trace
  end
  
  def self.inv(a)
    a.inverse
  end
  
  def self.transpose(a)
    a.transpose
  end

  def self.symmetric?(a)
    a.symmetric?
  end
end