# export DISPLAY=172.17.160.1:0
#! /bin/bash
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"
CA65_INC=/usr/share/cc65/asminc/
# -DWITH_DEBUG=1

ca65 --cpu 6502 --verbose -s -ttelestrat  src/systemd.asm -o tmp/systemd.ld65 --debug-info > memmap.md
RET=$?
if [ $RET != 0 ]
then
echo Error
exit
fi

ld65 -tnone  tmp/systemd.ld65 -o systemd.rom -Ln tmp/systemd.sym -m tmp/memmap.txt -vm

mkdir -p $ORICUTRON_PATH/sdcard/usr/share/systemd
cp systemd.rom $ORICUTRON_PATH/sdcard/usr/share/systemd

cp build/bin/twiload  $ORICUTRON_PATH/sdcard/bin

#echo cp systemd.rom $ORICUTRON_PATH/sdcard/usr/share/systemd
cp systemd.rom $ORICUTRON_PATH/roms
mkdir $ORICUTRON_PATH/sdcard/etc/systemd
cp etc/systemd/roms.cnf $ORICUTRON_PATH/sdcard/etc/systemd/
cd $ORICUTRON_PATH
./oricutron
cd -

