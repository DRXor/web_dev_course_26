require 'date'

#определяем аргументы 
if ARGV.length != 4
  puts "ruby build_calendar.rb teams.txt 01.08.26 01.06.27 calendar.txt"
  exit
end

teams_file = ARGV[0]
start_date_str = ARGV[1]
end_date_str = ARGV[2]
output_file = ARGV[3]

#проверяем даты
begin
  start_date = Date.strptime(start_date_str, '%d.%m.%Y')
  end_date = Date.strptime(end_date_str, '%d.%m.%Y')
rescue
  puts "Ошибка: неверный формат даты. Используйте ДД.ММ.ГГ"
  exit
end

if end_date <= start_date
  puts "Ошибка: конечная дата должна быть позже начальной"
  exit
end

#чтение файла и запись команд
teams = []
File.readlines(teams_file, encoding: "UTF-8").each do |line|
  line.strip!
  next if line.empty?

  line = line.sub(/^\d+\.\s*/, "")
  parts = line.split(" — ")
  if parts.length != 2
    puts "Ошибка в формате строки"
    exit
  end

  name = parts[0].strip
  city = parts[1].strip
  
  if name.empty? || city.empty?
    puts "Ошибка: пустое имя команды или название города"
    exit
  end 

  teams << {name: name, city: city}
end

if teams.length < 2
  puts "Ошибка: должно быть минимум 2 команды"
  exit
end

#создаём список всех матчей
matches = []

teams.combination(2).each do |team1, team2|
  matches << {
    home: team1,
    away: team2
  }
end

#определяем возможные игровые даты
game_days = []
current_date = start_date

while current_date <= end_date
  if [5, 6, 0].include?(current_date.wday)
    game_days << current_date
  end
  current_date += 1
end

if game_days.empty?
  puts "Ошибка: в выбранном диапазоне нет игровых дней"
  exit
end

#допустимое время для игр
time_slots = ["12.00", "15.00", "18.00"]
fields = 2 #макс 2 игры одновременно - 2 поля

schedule = []
match_index = 0
total_matches = matches.length

game_days.each do |date|
  time_slots.each do |time|
    fields.times do |field|
      break if match_index >= total_matches

      schedule << {
        date: date,
        time: time,
        match: matches[match_index]
      }

      match_index += 1
    end
  end

  break if match_index >= total_matches
end

if match_index < total_matches
  puts "Ошибка: недостаточно дат для размещения всех матчей"
  exit
end

#запись в файл
File.open(output_file, "w") do |file|
  file.puts "Спортивный календарь"
  file.puts "Период: #{start_date.strftime("%d.%m.%y")} - #{end_date.strftime("%d.%m.%y")}"
  file.puts " "

  schedule.each do |game|
    date_str = game[:date].strftime("%A, %d.%m.%y")
    #date_str = date_str.encode("UTF-8")
    #
    home = game[:match][:home]
    away = game[:match][:away]

    file.puts "#{date_str} | #{game[:time]}"
    file.puts " #{home[:name]} vs #{away[:name]}"
    file.puts " "
  end
end

puts "Календарь успешно создан в файле 'output_file'"



