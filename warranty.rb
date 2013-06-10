#!/usr/bin/env ruby

#####################################################################
#  Name: Applecare Warranty Check
#  Author: Riley Shott
#  Date: June 9, 2013
#  Version: 0.1.0
#  Description: Checks whether or not the given serial(s) are covered under the AppleCare Protection Plan.
#               This is just a quick script to demonstrate that you can get a JSON formatted response with Applecare information.
#####################################################################

### LIBRARIES ###

begin
  require 'uri'
  require 'net/https'
  require 'rubygems'
  require 'json'
rescue LoadError
  puts "Could not load required library"
  exit 1
end

### CONSTANTS ###

URL = URI.parse('https://expresslane.apple.com')
HTTP = Net::HTTP.new(URL.host, URL.port)
HTTP.use_ssl = true
HTTP.verify_mode = OpenSSL::SSL::VERIFY_NONE

### METHODS ###

# Returns the session cookies needed to reach the warranty page
def get_session_cookies
  begin
    resp = HTTP.get('/GetproductgroupList.action')
    cookie = resp.response['set-cookie']

    headers = {
      'Cookie' => cookie,
      's_cc'   => 'true',
      's_orientation' => '[[B]]',
      's_sq'=> '[[B]]',
      's_orientationHeight' => '731',
    }
  rescue => e
    puts "An error occured while getting the session cookies"
    puts e.backtrace
    exit 1
  end
end

# Returns a hash object with a Mac's warranty status
def get_warranty_info(serial, cookies)
  begin
    resp = HTTP.get("/Coverage.action?serialId=#{serial}", cookies)
    hash = JSON.parse(resp.body)
  rescue => e
    puts "An error occured checking this serial - #{serial}"
    puts e.backtrace
  end

end

def valid_warranty_hash?(hash)
  return false unless hash['strRespCd'].eql?('00')
  true
end

def app?(hash)
  return true if ((hash['strHwCoverage'].eql?('PP')) and (hash['strPhCoverage'].eql?('PP')))
  false
end

### MAIN ###

if (ARGV[0].eql?('-h') or ARGV[0].eql?('--help'))
  puts "Usage: #{__FILE__} serial1 serial2 serial3 etc..."
  exit 0
end

if ARGV.empty?
  puts "No serial number given. Proceeding with the local serial number."
  ARGV[0] = %x(system_profiler SPHardwareDataType | grep -v tray |awk '/Serial/ {print $4}').upcase.chomp
end

session_cookies = get_session_cookies

ARGV.each do |serial|
  warranty = get_warranty_info(serial, session_cookies)
  if valid_warranty_hash?(warranty)
    has_app = app?(warranty)
    puts "\nSerial Number:      #{warranty['strEntSlNo']}"
    puts "Eligible for APP:   #{warranty['strAppEligible']}" unless has_app
    puts "Has APP:            #{has_app}"
    puts "Hardware Coverage:  #{warranty['strHwCovStatus']}"
    puts "Phone Coverage:     #{warranty['strPhCovStatus']}"
    puts "Days Left:          #{warranty['strPhDaysLeft']}\n" # Not sure what exactly this indicates. Adding this value from the current date did not add up to the expiry of my AppleCare
  else
    puts "\nAn error occured while checking this serial - #{serial}"
  end
end

puts "\nPlease be aware that the days left value may not be accurate. It is shown for demonstrational purposes only. See comment on line 94 for more information"

exit 0

