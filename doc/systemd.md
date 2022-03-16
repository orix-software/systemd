# Systemd Rom v2022.1.2

Systemd is located in /usr/share/systemd folder (systemd.rom) and provides loader and firmware menu

## Requires

This roms requires at least Orix 2022.1 (kernel : 2022.1 and Shell : 2022.1)
Systemd.rom must be in /usr/share/systemd folder (systemd.rom) and can be downloaded here : http://repo.orix.oric.org/dists/official/tgz/6502/systemd.tgz

## Twilighte setup

Uses *funct + T* to launch the menu or type "twiconf" if you have Oric-1 keyboard

![alt text](firmware.jpg "firmware")

It displays informations as :

* The firmware version, it's the firmware of the twilighte board there is two versions : 1 and 2. The version '2' handles the "microdisc register"
* The cpu installed in the Oric. Please note that the cards seems to work with 65C816 with some Oric
* The default storage : It's provided by kernel rom. If kernel usb is installed, usb device is the default storage.
* Usb firmware version : The firmware of the usb controler
* Microdisc register : if it's present, some extra software can works : ripped, Osid music etc, and cumulus can be plugged Floppy disk can be started

### Displays all Orix roms

![alt text](firmware_bank_display.jpg "Displays bank")

## Twilighte loader

Uses funct + L to launch the menu or type "twiload" if you have Oric-1 keyboard

![alt text](loader2.jpg "firmware")

You can select the rom you want to start :
* For atmos (usbdrive or sdcard), root path of the rom is /home/basic11 
* For Oric-1 (usbdrive or sdcard), root path of the rom is /home/basic10
* For Pravetzt (usbdrive or sdcard), root path of the rom is /home/pravetzt

and others Roms

Loader can starts tape file as atmos .tap file by category (demo, games).

Demo, games, tools, music categories displays atmos tape file and Oric-1 tapes files. It means that loader is able to start atmos software only and Oric-1 only.

In order to avoid 2 softwares for Oric-1 and another one for atmos when it's available for theses 2 machines, the choice is that loader displays atmos tape file, and if the software does not exist on the atmos, Oric-1 version is displayed.

Number of software for each category since 2/3/2022

* Demo : 22
* Games : 677
* Tools : 117
* Music : 80

## Issues

It's a usable beta version, a lot of roms works, but here are issues :

* Dflat roms works but keyboard is not working on some oric (work in progress)

## Credits

* Assinie : Oric-1, atmos, pravetz ROM for usb/sdcard controler code
* Gweg : Gfx menu (icons, frames)
