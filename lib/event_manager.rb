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
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
=begin  
  if zipcode.nil?
    zipcode = "00000"
  elsif zipcode.length > 5
    zipcode = zipcode.first(5)
  elsif zipcode.length < 5 
    zipcode = zipcode.rjust 5, "0"
  else
    zipcode
  end
=end
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phonenumber)
  phonenumber = phonenumber.split(/\W+/).join()
  if phonenumber.length < 10 || (phonenumber.length >= 11 && phonenumber[0] != 1) || phonenumber.length > 11
    phonenumber = "0"
  elsif phonenumber.length == 11 && phonenumber[0] == 1
    phonenumber = phonenumber[1...phonenumber.length]
  else
    phonenumber
  end

end
def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
=begin
  legislator_names = legislators.collect do |legislator|
    "#{legislator.first_name} #{legislator.last_name}"
  end
  legislator_names.join(", ")
=end
end

def save_thank_you_letters(id, form_letter)
   Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end
$reg_freq ={}
def time_target(regdate)

  regdate = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
  if $reg_freq.keys.include?(regdate.hour)
      $reg_freq[regdate.hour] += 1
  else
    $reg_freq[regdate.hour] = 1
  end
end

$day_freq={}
def weekday(regdate)
  regdate = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
  if $day_freq.keys.include?(regdate.wday)
    $day_freq[regdate.wday] += 1
  else
    $day_freq[regdate.wday] = 1
  end
end


puts "EventManager initialized"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_phone_numbers(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  time_target(row[:regdate])
  weekday(row[:regdate])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)

end
puts $reg_freq

testing = Hash[$day_freq.map{|keys, value|
  [(case keys
  when 0
    "Sunday"
  when 1
    keys = "Monday"
  when 2
    keys = "Tuesday"
  when 3
    keys = "Wednesday"
  when 4
    keys = "Thursday"
  when 5
    keys = "Friday"
  when 6
    keys = "Saturday"
  end), value
  ]}.flatten]
puts testing
puts $day_freq