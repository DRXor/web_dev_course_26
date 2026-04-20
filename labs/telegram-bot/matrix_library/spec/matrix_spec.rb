require_relative '../lib/matrix'

RSpec.describe Matrix do
  describe "#initialize" do
    it "создаёт матрицу заданного размера с нулями" do
      matrix = Matrix.new(2, 3)
      expect(matrix.rows).to eq(2)
      expect(matrix.cols).to eq(3)
      expect(matrix[0, 0]).to eq(0)
    end

    it "создаёт матрицу из двумерного массива" do
      matrix = Matrix.new([[1, 2], [3, 4]])
      expect(matrix.rows).to eq(2)
      expect(matrix.cols).to eq(2)
      expect(matrix[0, 0]).to eq(1)
      expect(matrix[1, 1]).to eq(4)
    end
  end

  describe ".identity" do
    it "создаёт единичную матрицу" do
      matrix = Matrix.identity(3)
      expect(matrix[0, 0]).to eq(1)
      expect(matrix[0, 1]).to eq(0)
      expect(matrix[1, 1]).to eq(1)
      expect(matrix[2, 2]).to eq(1)
    end
  end

  describe "#+" do
    it "складывает две матрицы" do
      a = Matrix.new([[1, 2], [3, 4]])
      b = Matrix.new([[5, 6], [7, 8]])
      c = a + b
      expect(c[0, 0]).to eq(6)
      expect(c[1, 1]).to eq(12)
    end

    it "выбрасывает ошибку при разных размерах" do
      a = Matrix.new(2, 2)
      b = Matrix.new(3, 3)
      expect { a + b }.to raise_error(ArgumentError)
    end
  end

  describe "#*" do
    it "умножает две матрицы" do
      a = Matrix.new([[1, 2], [3, 4]])
      b = Matrix.new([[2, 0], [1, 2]])
      c = a * b
      expect(c[0, 0]).to eq(4)  # 1*2 + 2*1 = 4
      expect(c[0, 1]).to eq(4)  # 1*0 + 2*2 = 4
      expect(c[1, 0]).to eq(10) # 3*2 + 4*1 = 10
      expect(c[1, 1]).to eq(8)  # 3*0 + 4*2 = 8
    end

    it "умножает матрицу на скаляр" do
      a = Matrix.new([[1, 2], [3, 4]])
      b = a * 2 
      expect(b[0, 0]).to eq(2)  # 1 * 2 = 2
      expect(b[0, 1]).to eq(4)  # 2 * 2 = 4
      expect(b[1, 0]).to eq(6)  # 3 * 2 = 6
      expect(b[1, 1]).to eq(8)  # 4 * 2 = 8
    end
  end

  describe "#determinant" do
    it "вычисляет детерминант для матрицы 1x1" do
      matrix = Matrix.new([[5]])
      expect(matrix.determinant).to eq(5)
    end

    it "вычисляет детерминант для матрицы 2x2" do
      matrix = Matrix.new([[1, 2], [3, 4]])
      expect(matrix.determinant).to eq(-2)
    end

    it "вычисляет детерминант для матрицы 3x3" do
      matrix = Matrix.new([[6, 1, 1], [4, -2, 5], [2, 8, 7]])
      expect(matrix.determinant).to eq(-306)
    end
  end

  describe "#inverse" do
    it "вычисляет обратную матрицу для 2x2" do
      matrix = Matrix.new([[4, 7], [2, 6]])
      inv = matrix.inverse
      product = matrix * inv

      expect(product[0, 0]).to be_within(0.0001).of(1)
      expect(product[0, 1]).to be_within(0.0001).of(0)
      expect(product[1, 0]).to be_within(0.0001).of(0)
      expect(product[1, 1]).to be_within(0.0001).of(1)
    end
  end

  describe "#transpose" do
    it "транспонирует матрицу" do
      matrix = Matrix.new([[1, 2, 3], [4, 5, 6]])
      transposed = matrix.transpose
      expect(transposed.rows).to eq(3)
      expect(transposed.cols).to eq(2)
      expect(transposed[0, 0]).to eq(1)
      expect(transposed[2, 1]).to eq(6)
    end
  end
end