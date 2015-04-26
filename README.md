Requirements
============

* Keep existing Windows installation.


Problems and Solutions
======================


USB Dongle
----------

Installing from USB dongle wasn't as trivial as it may seem. First of all
simply copying ISO image in to USB key doesn't work. Lenovo can not boot it.

Another issue is that X1 Carbon requires non-free firmware, so that is another
thing that has to be added in to USB dongle.

Script [`mk-usb.sh`](mk-usb.sh) describes how this issue was solved.


Disk Partitioning
-----------------

Disk already uses all four primary partitions. Disk still uses old DOS-style
partition table, therefore that is maximum number of primary partitions
allowed.

To acquire at leas one primary partition, under which logical partitions can be
created, one has to delete at least one of those existing partitions. After
some thinking it was decided to delete recovery partition. Before doing so, USB
recovery partition was created using Lenovo recovery tools. Old recovery
partition was also backed up by simply dd-ing it in to image file on external
USB drive.

    dd if=/dev/sda3 of=/mnt/ext-hdd/lenovo-x1-carbon-q-rescue-disk.img

That "q" in the name of the image file indicated drive letter assigned to it
under Windows.

Don't forget to backup USB recovery disk as well. In my case it USB key had
`/dev/sdc` device assigned to it:

    dd if=/dev/sdc of=/mnt/ext-hdd/lenovo-x1-carbon-usb-rescue-disk-32g.img

Suffix "32g" of the target file name indicates, that USB key had size of 32GB.


Oracle Java on Debian
---------------------

See <http://www.webupd8.org/2012/06/how-to-install-oracle-java-7-in-debian.html>
and [`install-packages.sh`](install-packages.sh) script.
