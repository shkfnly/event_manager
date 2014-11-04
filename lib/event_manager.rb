=begin
puts "EventManager initialized."

if File.exist? "event_attendees.csv"
    lines = File.readlines "event_attendees.csv"
    lines.each_with_index do |line|
      next if index == 0
      columms = line.split(",")
      name = columms[2].downcase.capitalize
      puts name
    end
end
=end

require "csv"
puts "EventManager initialized"

contents = CSV.open "event_attendees.csv", header: true
contents.each do |row|
  name = row[2]
  puts name
end