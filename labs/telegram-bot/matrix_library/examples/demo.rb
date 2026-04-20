require_relative '../lib/matrix'

puts "=" * 50
puts "     ДЕМОНСТРАЦИЯ БИБЛИОТЕКИ ДЛЯ РАБОТЫ С МАТРИЦАМИ"
puts "=" * 50

# 1. Создание матриц разными способами
puts "\n1. СОЗДАНИЕ МАТРИЦ:\n"
puts "-" * 30

# Пустая матрица 2x3
m1 = Matrix.new(2, 3)
puts "Пустая матрица 2x3 (все нули):"
puts m1
puts

# Из двумерного массива
m2 = Matrix.new([
  [1, 2, 3],
  [4, 5, 6]
])
puts "Матрица из двумерного массива 2x3:"
puts m2
puts

m3 = Matrix[
  [1, 2],
  [3, 4],
  [5, 6]
]
puts "Матрица 3x2 через Matrix[][]:"
puts m3
puts

# Единичная матрица
i3 = Matrix.identity(3)
puts "Единичная матрица 3x3:"
puts i3

# 2. Доступ к элементам
puts "\n2. ДОСТУП К ЭЛЕМЕНТАМ:\n"
puts "-" * 30

matrix = Matrix[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
puts "Исходная матрица 3x3:"
puts matrix

puts "\nЭлемент [1, 1]: #{matrix[1, 1]}"
puts "Элемент [0, 2]: #{matrix[0, 2]}"

matrix[2, 2] = 99
puts "\nПосле изменения элемента [2, 2] на 99:"
puts matrix

puts "\nСтрока 1: #{matrix.row(1).inspect}"
puts "Столбец 1: #{matrix.col(1).inspect}"

# 3. Арифметические операции
puts "\n3. АРИФМЕТИЧЕСКИЕ ОПЕРАЦИИ:\n"
puts "-" * 30

a = Matrix[[1, 2], [3, 4]]
b = Matrix[[5, 6], [7, 8]]

puts "Матрица A:"
puts a
puts "\nМатрица B:"
puts b

puts "\nA + B:"
puts a + b

puts "\nA - B:"
puts a - b

puts "\nA * B (умножение матриц):"
puts a * b

puts "\nA * 2 (умножение на скаляр):"
puts a * 2

puts "\nA / 2 (деление на скаляр):"
puts a / 2

# 4. Транспонирование
puts "\n4. ТРАНСПОНИРОВАНИЕ:\n"
puts "-" * 30

matrix = Matrix[[1, 2, 3], [4, 5, 6]]
puts "Исходная матрица 2x3:"
puts matrix
puts "\nТранспонированная матрица 3x2:"
puts matrix.transpose

# 5. Определитель (детерминант)
puts "\n5. ОПРЕДЕЛИТЕЛЬ (ДЕТЕРМИНАНТ):\n"
puts "-" * 30

m2x2 = Matrix[[1, 2], [3, 4]]
puts "Матрица 2x2:"
puts m2x2
puts "det = #{m2x2.determinant}"
puts "det (через псевдоним) = #{m2x2.det}"
puts

m3x3 = Matrix[
  [6, 1, 1],
  [4, -2, 5],
  [2, 8, 7]
]
puts "Матрица 3x3:"
puts m3x3
puts "det = #{m3x3.determinant}"

# 6. Обратная матрица
puts "\n6. ОБРАТНАЯ МАТРИЦА:\n"
puts "-" * 30

m = Matrix[[4, 7], [2, 6]]
puts "Исходная матрица:"
puts m

inv = m.inverse
puts "\nОбратная матрица:"
puts inv

puts "\nПроверка: A * A⁻¹ = I"
product = m * inv
puts product

# 7. След матрицы
puts "\n7. СЛЕД МАТРИЦЫ (TRACE):\n"
puts "-" * 30

m = Matrix[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
puts "Матрица:"
puts m
puts "След (trace) = #{m.trace}"

# 8. Проверка свойств
puts "\n8. ПРОВЕРКА СВОЙСТВ:\n"
puts "-" * 30

square = Matrix[[1, 2], [3, 4]]
non_square = Matrix[[1, 2, 3], [4, 5, 6]]
symmetric = Matrix[[1, 2, 3], [2, 4, 5], [3, 5, 6]]

puts "Квадратная матрица 2x2: square? = #{square.square?}"
puts "Неквадратная матрица 2x3: square? = #{non_square.square?}"
puts "\nСимметричная матрица:"
puts symmetric
puts "symmetric? = #{symmetric.symmetric?}"

# 9. Решение системы линейных уравнений
puts "\n9. РЕШЕНИЕ СИСТЕМЫ ЛИНЕЙНЫХ УРАВНЕНИЙ:\n"
puts "-" * 30

# Система:
# 3x + 2y = 8
#  x -  y = 1

A = Matrix[[3, 2], [1, -1]]
B = Matrix[[8], [1]] 

puts "Матрица коэффициентов A:"
puts A
puts "\nВектор правых частей B:"
puts B

# Решение
X = A.inverse * B
puts "\nРешение X = A⁻¹ * B:"
puts X
puts "x = #{X[0, 0]}, y = #{X[1, 0]}"

# Проверка
puts "\nПроверка: A * X ="
puts A * X
