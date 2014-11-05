#!/usr/bin/ruby

#####################################################################
#  Name: Google Drive Helper
#  Author: Riley Shott
#  Date: May 20, 2013
#  Version: 0.1.0
#  Description: Places the files Google Drive needs to modify folder icons,
#               which prevents it from asking for an Administrator password.
#####################################################################

require 'fileutils'

icon_helper        = '/Applications/Google Drive.app/Contents/Helpers/Google Drive Icon Helper'
icon_helper_path   = '/Library/PrivilegedHelperTools'
icon_helper_script = "#{icon_helper_path}/Google Drive Icon Helper"

exit 0 if File.exists? icon_helper_script

if File.exists? icon_helper
  begin
    FileUtils.cp icon_helper, icon_helper_path
    FileUtils.chmod 06755, icon_helper_script
    FileUtils.chown 'root', 'procmod', icon_helper_script
  rescue Exception => e
    message = 'An error occured:' + "\n\n" + "Error Message: " + e.message + "\n" + "Backtrace: " + e.backtrace.inspect
    puts message
  end
else
  puts "#{icon_helper} doesn't seem to exist."
  exit 1
end

exit 0
