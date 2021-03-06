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

Disk already uses all four primary partitions. Also, it still uses old
DOS-style partition table, therefore that is maximum number of primary
partitions allowed.

To acquire  primary partition, under which logical partitions can be created,
at least one of those existing partitions has to be deleted. After some
thinking it was decided to delete recovery partition. Before doing so, USB
recovery partition was created using Lenovo recovery tools. Old recovery
partition was also backed up by simply dd-ing it in to image file on external
USB drive.

    dd if=/dev/sda3 of=/mnt/ext-hdd/lenovo-x1-carbon-q-rescue-disk.img

That "q" in the name of the image file indicated drive letter assigned to it
under Windows.

Don't forget to backup USB recovery disk as well. In my case, USB key had
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


Firefox, Thunderbird, SeaMonkey
-------------------------------

There is a project named [Ubuntuzilla: Mozilla Software Installer][], which
provides:

* Firefox
* Thunderbird
* SeaMonkey

All the above applications are unmodified binary distributions from Mozilla
Foundation.

Purge `iceweasel` and possibly also `icedove` packages.

Changing Firefox locale to Czech is done by installing language pack addon and
then in <about:config> change value of `general.useragent.locale` to `cs-CZ`
and restart Firefox.

To change Thunderbird locale to Czech, go to
<https://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/>, find version
you are using and inside than go to directory `linux-x86_64/xpi/` and follow
instructions in <http://kb.mozillazine.org/Extensions_%28Thunderbird%29>.

To set DPI higher, so that it these applications are usable on high resolution
displays, set `layout.css.devPixelsPerPx` to either `2` or `1.5`. References:
<https://askubuntu.com/questions/487032/adjust-firefox-and-thunderbird-to-a-high-dpi-touchscreen-display-retina>
<http://fedoramagazine.org/how-to-get-firefox-looking-right-on-a-high-dpi-display-and-fedora/>


Chrome
------

Just download Chrome Debian package from its [download page
][Chrome download page], then install it using:

    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt-get install --fix-broken   # Install Google Chrome dependencies

Google Chrome package registers its own repository in:

    /etc/apt/sources.list.d/google-chrome.list


Bluetooth
---------

KDE Bluetooth integration, named BlueDevil, is not installed by default. Simple
`apt-get install bluedevil` will do. See also
[`install-packages.sh`](install-packages.sh).


SSD Trim
--------

Querying disk if it supports trim:

    $ sudo hdparm -I /dev/sda | grep -i trim
           *    Data Set Management TRIM supported (limit 8 blocks)

Enabling periodic `fstrim` using systemd timer:

    $ sudo cp /usr/share/doc/util-linux/examples/fstrim.{service,timer} /usr/lib/systemd/system/
    $ sudo systemctl daemon-reload
    $ sudo systemctl enable fstrim.timer
    $ sudo systemctl start fstrim.timer

References:

* <https://wiki.archlinux.org/index.php/Solid_State_Drives#Verify_TRIM_Support>
* <https://wiki.archlinux.org/index.php/Solid_State_Drives#Apply_periodic_TRIM_via_fstrim>
* <https://wiki.archlinux.org/index.php/systemd#Editing_provided_unit_files>
* <https://wiki.archlinux.org/index.php/Systemd/Timers>



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
