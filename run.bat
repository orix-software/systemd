

@echo off



rem SET ORICUTRON="D:\Onedrive\oric\oricutron_twilighte"
SET ORICUTRON="D:\Users\plifp\Onedrive\oric\oricutron_twilighte"
rem @SET ORICUTRON="D:\Onedrive\oric\projets\oric_software\oricutron_jedeoric\msvc\VS2019\x64\Release\"


SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

SET ROM=systemd
rem -DWITH_SDCARD_FOR_ROOT=1 
rem 
%CC65%\ca65.exe -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65  
%CC65%\ld65.exe -tnone  %ROM%.ld65 -o %ROM%.rom 

%CC65%\cl65.exe -ttelestrat src/commands/twilconf/main.c libs/lib8/twil.lib -o twiconf
%CC65%\cl65.exe -ttelestrat src/commands/loader/main.c libs/lib8/twil.lib -o twiload

IF "%1"=="NORUN" GOTO End
copy twiconf %ORICUTRON%\sdcard\bin\t > NUL
copy twiload %ORICUTRON%\sdcard\bin\l > NUL

copy %ROM%.rom %ORICUTRON%\sdcard\usr\share\systemd\ > NUL
copy %ROM%.rom %ORICUTRON%\roms > NUL
mkdir %ORICUTRON%\sdcard\etc\systemd
copy etc\systemd\modules %ORICUTRON%\sdcard\etc\systemd > NUL
rem copy etc\systemd\banks.cnf %ORICUTRON%\sdcard\etc\systemd > NUL

cd %ORICUTRON%

oricutron

:End
cd %ORIGIN_PATH%

