require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end
def legislators_by_zipcode(zip)
  civicinfo = Google::Apis::CivicinfoV2::CivicInfoService.new

  civicinfo.key = File.read('segredo.key.txt').strip
  begin
    legislators = civicinfo.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    rescue
      'You can find your representatives by visijntng xxx'
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
    puts formated_phone
  elsif formated_phone.to_s.length == 11 && formated_phone.to_s.split('').first == '1'
    puts formated_phone.to_s.split('').drop(1).join('')
  elsif formated_phone.to_s.length >= 11 && formated_phone.to_s.split('').first != '1'
    puts 'bad number'
  end
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
   
  
  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)
  homephone = phone_formated(phone)
  form_letter = erb_template.result(binding)
  # thank_you_letter(id, form_letter)
end

