#!/usr/bin/ruby

############################################################
#
# Title: Drupal Database Backup Utility
# Created: Nov 04, 2013
# Author: rshott@sfu.ca
# Version: 0.5
############################################################

### GLOBAL VARIABLES ###

DAY  = `/bin/date +\%d`.chomp.to_i
DATE = `/bin/date +\%Y-\%m-\%d`.chomp

### LIBRARIES ###

require 'fileutils'
require 'date'

### CLASSES ###

class Drupal

  attr_reader :site_name, :site_path, :dump_path

  def initialize(sites_path, dump_path)
    @site_name  = sites_path.split('/').last
    @site_path  = sites_path
    @dump_path  = dump_path
  end

  def backup
    unless File.exists?("#{@dump_path}/#{@site_name}/#{DATE}_#{@site_name}.tar.gz")
      Dir.chdir(@site_path)
      if File.exists?('./settings.php')
        FileUtils.mkdir_p("#{@dump_path}/#{@site_name}/#{DATE}_#{@site_name}", :mode => 0700)
        system("drush --result-file='#{@dump_path}/#{@site_name}/#{DATE}_#{@site_name}/#{site_name}.sql' --quiet sql-dump")
        md5 = `openssl md5 #{@dump_path}/#{@site_name}/#{DATE}_#{@site_name}/#{site_name}.sql | awk '{print $2}'`
        Dir.chdir("#{@dump_path}/#{@site_name}")
        File.open("#{DATE}_#{@site_name}/checksum.txt", 'w') { |f| f.write "#{@site_name}    #{md5}" }
        if system("tar cvfz #{DATE}_#{@site_name}.tar.gz #{DATE}_#{@site_name} && rm -rf #{DATE}_#{@site_name}")
          # Checking if we need to start archive
          cleanup if DAY > 28
        end
      end
    end
  end

  private
    # Finds the last dump backup in a month, archives it, and removes everything else
    def cleanup
      Dir.chdir("#{@dump_path}/#{@site_name}")
      files = Dir.glob("*_#{@site_name}.tar.gz").sort
      if files.collect { |x| x.split('-')[1] }.uniq.length > 1
        FileUtils.mkdir('monthly_archives', :mode => 0700 ) unless File.directory?('monthly_archives')
        latest = files.pop(2)[0]
        FileUtils.mv(latest, 'monthly_archives')
        FileUtils.rm(files, :force => true)
      end
    end

end

### SANITY CHECKS ###

if ARGV.length != 2 or ARGV[0].eql?('-h')
  puts "Usage: #{__FILE__} <drupal_sites_location> <dump_path>"
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

check = {}
error_messages = []

check['drush']   = system("which drush &> /dev/null")
check['openssl'] = system("which openssl &> /dev/null")
check['tar']     = system("which tar &> /dev/null")
check['rm']      = system("which rm &> /dev/null")
check.each do |key, value|
    error_messages << "This script requires #{key}. Please ensure it's installed and in your PATH." if value == false
end
unless error_messages.empty?
  puts error_messages
  exit 1
end

### MAIN ###

drupal_sites_location = File.expand_path(ARGV[0])
dump_path             = File.expand_path(ARGV[1])

Dir.glob("#{drupal_sites_location}/*").each do |site|
  drupal_site = Drupal.new(site, dump_path)
  drupal_site.backup
end

exit 0
