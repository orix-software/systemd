ca65.exe -ttelestrat  src/systemd.asm -o systemd.ld65  
ld65.exe -tnone  systemd.ld65 -o systemd.rom 
cp systemd.rom /s/usr/share/systemd