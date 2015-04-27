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


Etckeeper
---------

Directory `/etc` is stored in Git repository using [`etckeeper`][etckeeper]
tool.


Everpad
-------

There is [PPA repository providing everpad][Everpad PPA], last Ubuntu version
it supports is *Utopic Unicorn* (14.10). This causes problems with unresolvable
packages.

Trying to use Everpad directly from [repository][Everpad repository] on Debian
Jessie required to install different list of dependencies then listed on [how
to install page][Everpad: How to install]:

* `python-oauth2 --> python-oauth2client`
* `qmake --> qt4-qmake`

This also required small code change, import of oauth2 had to be changed to
import of oauth2client library.

Another issue is that DBus `.service` files have to be installed manually or by
adjusting [`scripts/install_dbus_services.py`
][Everpad: scripts/install\_dbus\_services.py] to use `/usr/local` as
installation prefix.

Now it timeouts on DBus calls to `com.everpad.App` api.


Flash Player
------------

[Adobe Flash Player download page][] says:

> NOTE: Adobe Flash Player 11.2 will be the last version to target Linux as a
> supported platform. Adobe will continue to provide security backports to
> Flash Player 11.2 for Linux.

On [Adobe AIR and Adobe Flash Player Team Blog: Adobe and Google Partnering for
Flash Player on Linux][Adobe and Google Partnering for Flash Player on Linux]
one can find out, that only Google Chrome will be providing newer versions of
Adobe Flash on Linux.


SeaMonkey
---------

There is a project named [Ubuntuzilla: Mozilla Software Installer][], which
provides:

* Firefox
* Thunderbird
* SeaMonkey

All the above applications are unmodified binary distributions from Mozilla
Foundation.


Chrome
------

Just download Chrome Debian package from its [download page
][Chrome download page], then install it using:

    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt-get install --fix-broken   # Install Google Chrome dependencies

Google Chrome package registers its own repository in:

    /etc/apt/sources.list.d/google-chrome.list



[Adobe Flash Player download page]:
  https://get.adobe.com/flashplayer/
[Adobe and Google Partnering for Flash Player on Linux]:
  https://blogs.adobe.com/flashplayer/2012/02/adobe-and-google-partnering-for-flash-player-on-linux.html
[Chrome download page]:
  https://www.google.com/chrome/browser/desktop/
[etckeeper]:
  https://joeyh.name/code/etckeeper/
[Everpad PPA]:
  https://launchpad.net/~nvbn-rm/+archive/ubuntu/ppa
[Everpad repository]:
  https://github.com/nvbn/everpad
[Everpad: How to install]:
  https://github.com/nvbn/everpad/wiki/how-to-install
[Everpad: scripts/install\_dbus\_services.py]:
  https://github.com/nvbn/everpad/blob/develop/scripts/install_dbus_services.py
[Ubuntuzilla: Mozilla Software Installer]:
  http://sourceforge.net/p/ubuntuzilla/wiki/Main_Page/
