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

License Terms
=============

All scripts in this repository are distributed using the MIT License:

Copyright (C) 2013 Riley Shott

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.