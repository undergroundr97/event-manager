require 'csv'
require 'google/apis/civicinfo_v2'


civicinfo = Google::Apis::CivicinfoV2::CivicInfoService.new

civicinfo.key = File.read('../segredo.key.txt').strip
puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  begin
  legislators = civicinfo.representative_info_by_address(
    address: zipcode,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody']
  )

  legislators = legislators.officials
  rescue
    'You can find your representatives by visijntng xxx'
  end
  puts "#{name} #{zipcode} #{legislators}"
end