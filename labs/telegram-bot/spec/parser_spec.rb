require_relative '../parser'
require 'matrix_library'

RSpec.describe 'Parser' do
  it 'парсит матрицу' do 
    m = parse_matrix("1,2;3,4")
    expect(m[0,0]).to eq(1)
    expect(m[1,1]).to eq(4)
  end

  it 'парсит матрицу с пробелами' do 
    m = parse_matrix(" 1 , 2 ; 3, 4  ")

    expect(m[0,0]).to eq(1)
    expect(m[0,1]).to eq(2)
    expect(m[1,0]).to eq(3)
    expect(m[1,1]).to eq(4)
  end
  it 'парсит матрицу с разными пробелами' do 
    m = parse_matrix("1, 2; 3,4")

    expect(m[1,1]).to eq(4)
  end

   it 'ошибка при пустом вводе' do 
    expect { parse_matrix("")}.to raise_error(ArgumentError)
  end

  it 'ошибка при некорректных числах' do 
    expect { parse_matrix("1,a;3,4")}.to raise_error(ArgumentError)
  end

  it 'ошибка при некорректном вводе' do
    expect { parse_matrix("abc")}.to raise_error(ArgumentError)
  end
end