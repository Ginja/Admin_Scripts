#!/usr/bin/ruby

#####################################################################
#  Name: Dropbox Helper
#  Author: rshott@sfu.ca
#  Date: March 29, 2013
#  Version: 0.1.0
#  Description: Places the files Dropbox needs to modify folder icons,
#               which prevents Dropbox from asking for an Administrator password.
#####################################################################

require 'fileutils'

dropbox_tgz         = '/Applications/Dropbox.app/Contents/Resources/DropboxHelperInstaller.tgz'
dropbox_script_path = '/Library/DropboxHelperTools'
dropbox_script      = "#{dropbox_script_path}/DropboxHelperInstaller"

unless Process.euid == 0
  puts 'This must be run as root.'
  exit 1
end

# Don't need to do anything
exit 0 if File.exists?(dropbox_script)

if File.exists?(dropbox_tgz)
  begin
    FileUtils.mkdir(dropbox_script_path, :mode => 0755)
    Dir.chdir(dropbox_script_path)
    system("/usr/bin/tar xfz #{dropbox_tgz}")
    FileUtils.chmod(04511, dropbox_script)
    system("xattr -d com.apple.quarantine #{dropbox_script}")
    FileUtils.chown('root', 'wheel', dropbox_script)
  rescue Exception => e
    message = 'An error occured:' + "\n\n" + "Error Message: " + e.message + "\n" + "Backtrace: " + e.backtrace.inspect
    puts message
  end
else
  puts "#{dropbox_tgz} doesn't seem to exist."
  exit 1
end

exit 0