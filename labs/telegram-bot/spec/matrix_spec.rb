require 'matrix_library'
require_relative '../services/matrix_service'

RSpec.describe Matrix do
  it 'складывает матрицы корректно' do 
    a = Matrix[[1,2],[3,4]]
    b = Matrix[[1,1],[1,1]]

    result = a + b

    expect(result.to_a).to eq([[2,3],[4,5]])
  end

  it 'умножает матрицы' do
    a = Matrix[[1,2],[3,4]]
    b = Matrix[[1,0],[0,1]]

    result = MatrixService.mul(a, b)

    expect(result.to_a).to eq([[1,2],[3,4]])
  end

  it 'считает определитель' do
    a = Matrix[[1,2],[3,4]]
    expect(a.det).to eq(-2)
  end

  it 'считает детерминант 1х1 матрицы' do
    a = Matrix[[5]]
    expect(a.det).to eq(5)
  end

  it 'ошибка при сложении матриц разного размера' do
    a = Matrix[[1,2]]
    b = Matrix[[1,2],[3,4]]

    expect {a + b}.to raise_error(Exception)
  end
end