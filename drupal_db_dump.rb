#!/usr/bin/ruby

############################################################
#
# Title: Drupal Database Backup Utility
# Created: Nov 04, 2013
# Author: rshott@sfu.ca
# Version: 0.7
############################################################

### GLOBAL VARIABLES ###

DAY   = `date +\%d`.chomp.to_i
MONTH = `date +\%m`.chomp.to_i
YEAR  = `date +\%Y`.chomp.to_i
DATE  = "#{YEAR}-#{MONTH}-#{DAY}"
USAGE = <<EOF
Usage: #{__FILE__} <drupal_sites_location> <dump_path> [archive]

Example: #{__FILE__} /var/www/drupal/drupal-7x/sites /var/www/drupal/database_dumps archive
Example: #{__FILE__} /var/www/drupal/drupal-7x/sites /var/www/drupal/database_dumps

Options:
  archive         If specified, will purge all but the last backup for the previous month when a new month begins.
EOF

### LIBRARIES ###

require 'fileutils'

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
          # Check if we need to archive
          cleanup if DAY > 28 && ARGV[2].eql?('archive')
        end
      end
    end
  end

  private
    # Purge all but the last backup for the previous month when a new month begins
    def cleanup
      Dir.chdir("#{@dump_path}/#{@site_name}")
      files = Dir.glob("*_#{@site_name}.tar.gz").sort
      month_count = files.collect { |x| x.split('-')[1] }.uniq.length
      if month_count == 2
        begin
          year, month = last_backup_period
          FileUtils.mkdir('monthly_archives', :mode => 0700 ) unless File.directory?('monthly_archives')
          last_months_files = Dir.glob("#{year}-#{month}-*_#{@site_name}.tar.gz").sort
          FileUtils.mv(last_months_files.pop, 'monthly_archives')
          FileUtils.rm(last_months_files, :force => true)
        rescue Exception => e
          message = 'An error occured while trying to archive for #{@site_name}:' + "\n\n" + "Error Message: " + e.message + "\n" + "Backtrace: " + e.backtrace.inspect
          puts message
        end
      elsif month_count >= 3
        puts "Backups span more than two months for #{@site_name}. Please manually resolve this if you want this functionality to work."
      end
    end

    def last_backup_period
      if MONTH == 1
        return YEAR - 1, 12
      else
        return YEAR, MONTH - 1
      end
    end

end

### SANITY CHECKS ###

if ARGV[0].eql?('-h') || ARGV[0].eql?('--help')
  puts USAGE
  exit 0
end

case ARGV.length
when 2
when 3
else
  puts USAGE
  exit 1
end

error_messages = []
error_messages << "The drupal sites location needs to be an existing directory - #{ARGV[0]}" unless File.directory?(ARGV[0])
error_messages << "The dump location needs to be an existing directory - #{ARGV[1]}" unless File.directory?(ARGV[1])
error_messages << "The third parameter either needs to be 'archive' or not specified at all - #{ARGV[2]}" unless ARGV[2].eql?('archive') or ARGV[2].nil?

check = {}

check['drush']   = system("which drush &> /dev/null")
check['openssl'] = system("which openssl &> /dev/null")
check['tar']     = system("which tar &> /dev/null")
check['rm']      = system("which rm &> /dev/null")
check['date']    = system("which date &> /dev/null")
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
