ca65 -ttelestrat  src/systemd.asm -o systemd.ld65
ld65 -tnone  systemd.ld65 -o systemd.rom
cp systemd.rom /mnt/s/usr/share/systemd
# cp etc/systemd/banks.cnf /s/etc/systemd/
mkdir -p /mnt/s/usr/share/systemd/roms/
# cp usr/share/systemd/roms/*.rom /mnt/s/usr/share/systemd/roms/