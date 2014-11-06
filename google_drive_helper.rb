#!/usr/bin/ruby

#####################################################################
#  Name: Google Drive Helper
#  Author: Riley Shott
#  Date: May 20, 2013
#  Version: 0.2.0
#  Description: Places the files Google Drive needs to modify folder icons,
#               which prevents it from asking for an Administrator password.
#####################################################################

require 'fileutils'

APP_PATH = '/Applications/Google Drive.app/Contents'

unless Process.euid == 0
  puts 'This must be run as root.'
  exit 1
end

# Check both paths for the Helper binary (newer, older) 
# Thanks to Dan Keller (https://github.com/dankeller) for informing me the path had changed
icon_helper = ["#{APP_PATH}/Helpers/Google Drive Icon Helper", "#{APP_PATH}/Resources/Google Drive Icon Helper"].collect do |file|
  file if File.exist? file
end.compact.first
icon_helper_path   = '/Library/PrivilegedHelperTools'
icon_helper_script = "#{icon_helper_path}/Google Drive Icon Helper"

unless icon_helper.nil?
  begin
    FileUtils.cp icon_helper, icon_helper_path, :preserve => true
    FileUtils.chmod 06755, icon_helper_script
    FileUtils.chown 'root', 'procmod', icon_helper_script
  rescue => e
    message = 'An error occured:' + "\n\n" + "Error Message: " + e.message + "\n" + "Backtrace: " + e.backtrace.inspect
    puts message
  end
else
  puts "Could not find the 'Google Drive Icon Helper' binary."
  exit 1
end

exit 0
