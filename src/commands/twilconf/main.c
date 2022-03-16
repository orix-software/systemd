#include <stdio.h>
#include <string.h> 

#define VERSION "2022.1"

#include "../../../libs/usr/include/twil.h"

main(int argc, char *argv[]) {
    if (argc==2)   {
        if (strcmp(argv[1],"-v")==0) {
            printf("Version %s\n",VERSION);
            return;
        }
        if (strcmp(argv[1],"-i")==0) {
            printf("Twil lib version : %d\n",twil_lib_version());
            return;
        }        
    }

    twil_program_rambank_id("/usr/share/systemd/systemd.rom", 33,0xc003);
}