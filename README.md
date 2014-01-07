Admin Scripts
=============

1. chrome_auto-updates.rb
   * This script enables system wide automatic updates for Google Chrome. It should work for Chrome versions 18 and later.

2. iMac_Warranty_Check.rb
   * Script that checks iMac serial numbers (in a txt, or excel file) for their eligibility into the [iMac Seagate HDD Recall](http://www.apple.com/support/imac-harddrive/).

3. margarita
   * A startup script for the margarita webinterface, specifically for RHEL flavours. When put into /etc/init.d it can be configured with chkconfig.

4. network_avail.sh
   * A simple bash script that checks if a network connection is available by looking to see if there are any non-loopback interfaces. Useful to use when another script needs an active connection to work.

5. prsync_transfer
   * An rsync wrapper that will transfer all alpha characters from the source folder in parallel (batches of 4).
     It will transfer everything else serially:
       * non-alpha characters,
       * files/folders with leading whitespaces,
       * and files/folders that are hidden
     For more information see [here](http://rileyshott.wordpress.com/2012/12/03/maclinux-parallel-rsync-utility).

6. warranty.rb
   * Checks whether or not the given serial(s) are covered under the AppleCare Protection Plan. This is just a quick script to demonstrate that you can get a JSON formatted response with Applecare information.

7. dropbox_helper.rb
   * Places the files Dropbox needs to modify folder icons, which prevents Dropbox from asking for an Administrator password when it's first launched on a system.

8. google_drive_helper.rb
   * Places the files Google Drive needs to modify folder icons, which prevents it from asking for an Administrator password when it's first launched on a system.

9. munkimassappinfo
   * A quick script to perform makepkginfo on all .app files in a particular directory.

10. drupal_db_dump
  * A script that takes two or three parameters: a Drupal sites directory, a dump directory. and an archive toggle.
  * Order of operations:
    * Dump the database for each active site in the given sites directory,
    * Create an md5 checksum of each dump and write it to a file,
    * Tar up each dump and its checksum,
    * (Optional toggle) Purge all but the last dump of the previous month when a new months starts.
  * For more information see [here](http://rileyshott.wordpress.com/2013/11/19/linuxmac-backing-up-drupal-databases).

11. msdw (mysqldump wrapper)
  * A wrapper for the mysqldump command. Takes two or three parameters: the database(s) to dump, a dump directory, and an archive toggle. You can also pass in options to the mysqldump command (ex: MySQL user, and password).
  * Usage: ./msdw --databases database1,database2 --dump-path /path [-a] [-- mysqldump options]
  * ```./msdw -d database1,database2,database3 -p /path/to/store/dumps -a -- -u mysql_user --password=itsasecret```
  * Order of operations:
    * Dump the databases given,
    * Create an md5 checksum of each dump and write it to a file,
    * Tar up each dump and its checksum,
    * (Optional toggle) Purge all but the last dump of the previous month when a new months starts.

12. wpb (WordPress backup)
  * A utility to backup your WordPress site & database. As with msdw, you can pass in options to the mysqldump command.
  * Usage: ./wpb --database database_name --dump-path /path [-a] [-- mysqldump options]
  * ```./wpb -d wordpress -p /backups -a -- -u backupuser --password=foryoureyesonly```

License Terms
=============

All scripts in this repository are distributed using the MIT License:

Copyright (C) 2013 Riley Shott

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
