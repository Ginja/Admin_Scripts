#!/usr/bin/ruby

############################################################
#
# Title: Drupal Database Backup Utility
# Created: Nov 04, 2013
# Author: rshott@sfu.ca
# Version: 0.1
############################################################

### GLOBAL VARIABLES ###

DAYS_TO_KEEP = 31
DATE = `/bin/date +\%Y\%m\%d`.chomp

### LIBRARIES ###

require 'fileutils'
require 'date'

### SANITY CHECKS ###

if ARGV.length != 2
  puts "Usage: #{__FILE__} <drupal_sites_location> <dump_location>"
  puts "Example: #{__FILE__} /var/www/drupal/drupal-7x/sites /var/www/drupal/database_dumps"
  exit 1
end

unless File.directory?(ARGV[0])
  puts "The drupal sites location needs to be an existing directory - #{ARGV[0]}"
  exit 1
end

unless File.directory?(ARGV[1])
  puts "The dump location needs to be an existing directory - #{ARGV[1]}"
  exit 1
end

unless system("which drush &> /dev/null")
  puts "Could not find drush on this system. Please ensure it's in your PATH."
  exit 1
end

### METHODS ###

def cleanup(location)
  Dir.chdir(location)
  Dir.glob("*.sql").each do |file|
    # Only manage files we create
    if file =~ /\d+-cron-.*sql/
      file_date = file.split('-').first
      FileUtils.rm(file) if ((Date.today - Date.parse(file_date)).to_i > DAYS_TO_KEEP)
    end
  end 
end

### MAIN ###

drupal_sites_location = File.expand_path(ARGV[0])
dump_location         = File.expand_path(ARGV[1])

drupal_sites = Dir.glob("#{drupal_sites_location}/*")

drupal_sites.each do |site|
  site_name = site.split('/').last
  Dir.chdir(site)
  if File.exists?('./settings.php')
    unless File.directory?("#{dump_location}/#{site_name}")
      FileUtils.mkdir("#{dump_location}/#{site_name}", :mode => 0750)
    end
    system("drush --result-file='#{dump_location}/#{site_name}/#{DATE}-cron-#{site_name}.sql' --quiet sql-dump")
    cleanup("#{dump_location}/#{site_name}")
  end
end

exit 0
