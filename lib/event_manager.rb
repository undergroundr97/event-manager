require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

# puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  puts "User ZipCode: #{zipcode.to_s.rjust(5, '0')[0..4]}"
end
def legislators_by_zipcode(zip)
  civicinfo = Google::Apis::CivicinfoV2::CivicInfoService.new

  civicinfo.key = File.read('segredo.key.txt').strip
  begin
      civicinfo.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    rescue
      'You can find your representatives by visiting xxx'
    end
end
def thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename =  "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def phone_formated(phone)
  formated_phone = phone.gsub(/[^0-9]/, "").to_i
  if formated_phone.to_s.length < 10
    puts "bad number"
  elsif formated_phone.to_s.length == 10
    puts "User phone: #{formated_phone}"
  elsif formated_phone.to_s.length == 11 && formated_phone.to_s.split('').first == '1'
    puts "User phone: #{formated_phone.to_s.split('').drop(1).join('')}"
  elsif formated_phone.to_s.length >= 11 && formated_phone.to_s.split('').first != '1'
    puts 'bad number'
  end
end

def register(registration)
  array_time = []
  time_saved = Time.strptime(registration, "%m/%d/%Y %k:%M").to_s.split(' ')
  hours = time_saved[1].split(":")
  puts "Registation hour: #{hours.join(':')}"
  array_time << hours[0]
  hours_count = array_time.each_with_object(Hash.new(0)) do |hour, count|
    count[hour] += 1
  end
#  hours_count
 max_registrations = hours_count.values.max
 hours_count.select {|hour,count| count == max_registrations}
end
best_day_week = []
days_of_week = []
days = {0 => "Sunday",
1 => "Monday", 
2 => "Tuesday",
3 => "Wednesday",
4 => "Thursday",
5 => "Friday",
6 => "Saturday"}
def register_day(registration,days,days_of_week,best_day_week)
  time_saved = Time.strptime(registration, "%m/%d/%Y %k:%M").to_s.split(' ')
  day_saved = time_saved[0].split('-')
  integer_day = day_saved.map{|x| x.to_i}
   yr = integer_day.first + 2000
   mnth = integer_day[1]
   dy = integer_day[2]
   days_of_week << Date.new(yr,mnth,dy).wday
  
  total_days = days_of_week.each_with_object(Hash.new(0)) do |wkday, count|
    count[wkday] += 1
  end
   peak_day = total_days.values.max
   total_days.key(peak_day)
  placeholder_day = ""
  days.each do |day_num, name_day|
    if day_num == total_days.key(peak_day)
      placeholder_day += name_day
    end
  end
 best_day_week <<  placeholder_day
end
puts "Event Manager Initialized"
contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = row[:homephone]
  registration = row[:regdate]

  puts name
  zipcode = clean_zipcode(row[:zipcode])
  reg_day = register_day(registration,days,days_of_week,best_day_week)
  reg_hour = register(registration)
  puts legislators = legislators_by_zipcode(zipcode)
  homephone = phone_formated(phone)
  # # form_letter = erb_template.result(binding)
  # # thank_you_letter(id, form_letter)
  puts "--------"
end


puts "The best hours to adversite on website are between 13 and 16!"
puts "The best day to advertise on the website is: #{best_day_week.uniq.join}!"