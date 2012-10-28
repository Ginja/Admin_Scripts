#!/usr/bin/ruby

############################################################
#
# Title: iMac 1TB Seagate Hard Drive Replacement Program Check
# Created: Oct 23, 2012
# Author: rshott@sfu.ca
# Notes:
# => You'll need to install the roo gem if you want to use an Excel spreadsheet as the data source:
# 		sudo gem update --system
# 		sudo gem install roo
# => If you're using an Excel spreadsheet:
# => 	Make sure that your data starts on row 2, otherwise specify which row using the row_start parameter
# => 	Column A should be the serials, and column B can be anything but it should be identifiable (EX: hostname)
# => If you're using a TXT file:
# =>  	Ensure that it only contains one column containing the serial numbers
# => Apple Support page - http://www.apple.com/support/imac-harddrive/
# => Run from the command line: ./iMac_Warranty_Check.rb /path/to/file
#
############################################################

############################################################
# LIBRARIES
############################################################

begin
	require 'net/http'
	require 'net/https'
	require 'uri'
rescue LoadError => error
	missing_lib = error.message.split('no such file to load -- ').last
	puts "Load Error: #{missing_lib} is not installed"
end

############################################################
# CLASSES (overriding init method)
# Purpose: Prevents "warning: peer certificate won't be verified in this SSL session" from displaying
############################################################

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

############################################################
# METHODS
############################################################

def excel_to_hash(file_path, row_start=2)
	raise "File does not appear to exist - #{file_path}" unless File.exists?(file_path)
	begin
		require 'rubygems'
		require 'roo'
	rescue LoadError => error
		missing_lib = error.message.split('no such file to load -- ').last
		puts "Load Error: #{missing_lib} is not installed. View script notes!"
	end
	oo = Excelx.new(file_path) if file_path.end_with?('xlsx')
	oo = Excel.new(file_path) if file_path.end_with?('xls')
	oo.default_sheet = oo.sheets.first
	comps = Hash.new
	row_start.upto(oo.last_row) do |line|
		comps[oo.cell(line, 'A')] = oo.cell(line, 'B')
	end
	return comps
end

def txt_file_to_array(file_path)
	raise "File does not appear to exist - #{file_path}" unless File.exists?(file_path)
	comps = IO.readlines(file_path)
	# Ensure we have an array delineated by whitespace
	comps = comps.to_s.split(' ')
end

def rma_needed?(serial)
	uri = URI.parse("https://supportform.apple.com/201107/SerialNumberEligibilityAction.do?cb=iMacHDCheck.response&sn=#{serial}")
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	res = http.request_get(uri.path + '?' + uri.query)
	info = res.body.split('"')
	return true if info[7].eql?('Valid iMac SN has Seagate HDD - covered by program')
	return false
end

############################################################
# MAIN
############################################################

raise "Usage: #{$PROGRAM_NAME} [ Excel Sheet | TXT File ]" unless __FILE__ == $PROGRAM_NAME and !ARGV.empty?
raise "Usage: #{$PROGRAM_NAME} [ Excel Sheet | TXT File ] - More than one argument was passed" if ARGV.length > 1

if ARGV[0].end_with?('xlsx') or ARGV[0].end_with?('xls')
	computers = excel_to_hash(ARGV[0])
	puts "Ignore the 'Faraday' message"
	puts "Starting Check..."
	computers.each do |serial,host|
		puts "#{serial} belonging to #{host} needs an RMA" if rma_needed?(serial.gsub(/\s+/, ""))
	end 
else
	computers = txt_file_to_array(ARGV[0])
	puts "Starting Check..."
	computers.each {|serial|
		puts "#{serial} needs an RMA" if rma_needed?(serial.gsub(/\s+/, ""))
	}
end

puts "Finished Checking..."