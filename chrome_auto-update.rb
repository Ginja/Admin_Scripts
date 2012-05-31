#!/usr/bin/ruby

# This script enables system wide automatic updates for Google Chrome.
# It should work for Chrome versions 18 and later.

# Originally created in python by Hannes Juutilainen, hjuutilainen@mac.com
# Converted/updated to ruby by Riley Shott rshott@sfu.ca
# May 31, 2012

begin
  require 'osx/cocoa'
  require 'fileutils'
  include OSX
rescue LoadError
  puts "Load Error"
end
 
@chrome_path = "/Applications/Google Chrome.app"
@info_plist_path = "#{@chrome_path}/Contents/Info.plist"
@brand_path = "/Library/Google/Google Chrome Brand.plist"
@brand_key = "KSBrandID"
@tag_path = @info_plist_path
@tag_key = "KSChannelID"
@version_path = @info_plist_path
@version_key = "KSVersion"
 
def chrome_installed?
  if File.exists?(@chrome_path)
    return true
  else
    return false
  end
end
 
def open_plist()
  plist = NSMutableDictionary.dictionaryWithContentsOfFile(@info_plist_path)
end
 
def chrome_version()
  info_plist = open_plist()
  bundle_short_version = info_plist['CFBundleShortVersionString']
  return bundle_short_version
end
 
def chrome_KSUpdateURL()
  info_plist = open_plist()
  ks_update_url = info_plist['KSUpdateURL']
  return ks_update_url
end
 
def chrome_KSProductID()
  info_plist = open_plist()
  ks_product_id = info_plist['KSProductID']
  return ks_product_id
end
 
def keystone_path()
  keystone_path = "#{@chrome_path}/Contents/Versions"
  keystone_path << "/" << chrome_version() << "/Google Chrome Framework.framework/Frameworks/KeystoneRegistration.framework"
  return keystone_path
end
 
def keystone_install()
  install_script = keystone_path() << "/Resources/install.py"
  keystone_payload = keystone_path() << "/Resources/Keystone.tbz"
  if File.exists?(install_script) and File.exists?(keystone_payload)
 
    system(install_script,
                  "--install=" << keystone_payload,
                  "--root=/",
                  "--force")
    if $? == 0
      return true
    else
      warn "Keystone install failed!"
      return false
    end
  else
    warn "Install script or Keystone payload not found!"
    return false
  end
end
 
def register_chrome()
  ksadmin = "/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/ksadmin"
  if File.exists?(ksadmin)
    system(ksadmin,
                    "--register",
                    "--preserve-tttoken",
                    "--productid", chrome_KSProductID,
                    "--version", chrome_version(),
                    "--xcpath", @chrome_path,
                    "--url", chrome_KSUpdateURL(),
                    "--tag-path", @tag_path,
                    "--tag-key", @tag_key,
                    "--brand-path", @brand_path,
                    "--brand-key", @brand_key,
                    "--version-path", @version_path,
                    "--version-key", @version_key)        
      if $? == 0
        return true
      else
        warn "ksadmin execution failed!"
        return false
      end
    else
    warn "ksadmin command not found!"
    return false
  end
end
 
if __FILE__ == $PROGRAM_NAME
  unless Process.euid == 0
    raise "You must run this as root!"
  end
  if chrome_installed? == false
    raise "Google Chrome not installed!"
  end
  if keystone_install()
    puts "Keystone installed sucessfully"
  else
    raise "Keystone install failed!"
  end
  if register_chrome()
    puts "Chrome registered sucessfully"
  else
    raise "Failed to register Chrome!"
  end
end
