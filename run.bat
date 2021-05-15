

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





IF "%1"=="NORUN" GOTO End
rem mkdir %ORICUTRON%\sdcard\usr\share\systemd\
rem copy %ROM%.rom %ORICUTRON%\sdcard\usr\share\systemd\ > NUL
copy %ROM%.rom %ORICUTRON%\roms > NUL
rem copy systemd.rom %ORICUTRON%\sdcard\usr\share\systemd\systemd2.rom > NUL
mkdir %ORICUTRON%\sdcard\etc\systemd
copy etc\systemd\modules %ORICUTRON%\sdcard\etc\systemd > NUL

cd %ORICUTRON%

oricutron

:End
cd %ORIGIN_PATH%

