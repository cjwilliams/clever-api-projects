require 'net/https'
require 'json'

uri = URI('https://api.getclever.com/v1.1/sections')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request = Net::HTTP::Get.new(uri.request_uri)
request.basic_auth('DEMO_KEY','')

begin
  response = http.request(request)
  raise "#{response.header}" if response.code != "200"
rescue => error
  retries ||= 0
  if retries < 10
    retries += 1
    retry
  else
    raise error
  end
end

class_sizes = []
response_body = JSON.parse( response.body )
sections = response_body["data"]
total_sections = response_body["paging"]["count"]

sections.each do |section|
  class_sizes.push( section["data"]["students"].size )
end

if class_sizes.size == total_sections
  average_class_size = ( class_sizes.inject(0.0, :+) )/class_sizes.size
  standard_deviation_class_size = ( Math.sqrt( class_sizes.inject(0.0) { |total,value| ( total + ( value-average_class_size )**2 ) } ) )/class_sizes.size
  puts "Average Class Size: #{average_class_size}\nStandard Deviation: #{standard_deviation_class_size}"
else
  raise "Not all sections are present in response"
end