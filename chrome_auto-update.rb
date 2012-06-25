
#!/usr/bin/ruby
 
# This script enables system wide automatic updates for Google Chrome.
# It should work for Chrome versions 18 and later.
 
# Originally created in python by Hannes Juutilainen, hjuutilainen@mac.com
# Converted/updated to ruby by Riley Shott rshott@sfu.ca
# Streamlined by Brian Warsing (https://github.com/dayglojesus)
# June 13, 2012
 
require 'osx/cocoa'
require 'fileutils'
require 'pp'
include OSX
 
CHROME_PATH = '/Applications/Google Chrome.app'
CHROME_INFO_PLIST_PATH = "#{CHROME_PATH}/Contents/Info.plist"
BRAND_PATH = "/Library/Google/Google\ Chrome\ Brand.plist"
KSADMIN = '/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/ksadmin'
 
def open_plist(file)
  NSMutableDictionary.dictionaryWithContentsOfFile(file)
end
 
def msg(msg)
  tag = $PROGRAM_NAME
  time = Time.now
  puts("#{time} #{tag}: #{msg}")
end
 
def keystone_install(keystone_path)
  result = nil
  error_num = nil
  install_script = keystone_path + '/Resources/install.py'
  keystone_payload = keystone_path + '/Resources/Keystone.tbz'
  if File.exists?(install_script) and File.exists?(keystone_payload)
    result = system(install_script, "--install=#{keystone_payload}", '--root=/', '--force')
    error_num = $?.exitstatus
  else
    raise "Missing one or more resources: #{keystone_payload}, #{install_script}"
  end
  [result, error_num]
end
 
def register_chrome(plist)
  result = nil
  error_num = nil
  options = %Q{ --register --preserve-tttoken \
    --productid '#{plist['KSProductID']}' \
    --version '#{plist['CFBundleShortVersionString']}' \
    --xcpath '#{CHROME_PATH}' \
    --url '#{plist['KSUpdateURL']}' \
    --tag-path '#{CHROME_INFO_PLIST_PATH}' \
    --tag-key 'KSChannelID' \
    --brand-path '#{BRAND_PATH}' \
    --brand-key 'KSBrandID' \
    --version-path '#{CHROME_INFO_PLIST_PATH}' \
    --version-key 'KSVersion'
  }
  if File.exists?(KSADMIN)
    command = [KSADMIN, options.gsub!(/    /,' ')].join(' ')
    result = system(command)
    error_num = $?.exitstatus
  else
    raise "Missing one or more resources: #{KSADMIN}"
  end
  [result, error_num]
end
 
if __FILE__ == $PROGRAM_NAME
  unless Process.euid == 0
    raise "You must run this as root!"
  end
  unless File.exists?(CHROME_PATH)
    raise "Google Chrome not installed!"
  end
end
 
@plist = open_plist(CHROME_INFO_PLIST_PATH)
@keystone_path = "#{CHROME_PATH}/Contents/Versions/" + @plist['CFBundleShortVersionString'] + '/Google Chrome Framework.framework/Frameworks/KeystoneRegistration.framework'
 
result, error_num = keystone_install(@keystone_path)
unless result
  msg("Keystone install failed! [#{error_num}]") 
  exit error_num
end
 
result, error_num = register_chrome(@plist)
unless result
  msg("Failed to register Chrome! [#{error_num}]") 
  exit error_num
end
 
msg("Chrome successfully registered for autoupdates")
 
exit 0