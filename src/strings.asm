
str_not_found:
    .asciiz "Not found"

str_reading_modules:
    .byte " Loading modules ...",$0D,$0A,$00
str_reading_banks:
    .byte " Loading banks ...",$0D,$0A,$00    

path_cnf:
    .asciiz "/etc/systemd/systemd.cnf"	

str_done:
    .byte "Loading banks finished",$0D,$0A,0

systemd_starting:
   .byte " .........."
str_OK:   
   .byte $82,"[OK]",$0D,0
str_oom:
    .asciiz "Out of memory"
rom_signature:
	.byte   "Systemd " ; Space must be present
version:    
    .asciiz "v2022.1.2"

str_bank: 
    .asciiz "  "
str_starting:
    .asciiz "Starting systemd "    
str_token_path:
    .asciiz "path"    
str_token_autoexec:
    .asciiz "autoexec"    
str_nothing_to_read:    
    .asciiz "Nothing to read"
path_modules:    
    .asciiz "/etc/systemd/modules"	
path_banks:    
    .asciiz "/etc/systemd/banks.cnf"	

str_path_rom:
    .asciiz "/usr/share/systemd/systemd.rom"    

str_failed:
    .byte ".............."
str_failed_word:    
    .byte $81,"[FAILED]",$0D,$00
str_error_path_not_found:
    .byte "File not found : ",$00
