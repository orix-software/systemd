;.include   "../dependencies/orix-sdk/macros/SDK.mac"
.include   "../dependencies/orix-sdk/macros/strnxxx.mac"
.include   "../dependencies/orix-sdk/macros/SDK_print.mac"
.include   "../dependencies/orix-sdk/macros/SDK_memory.mac"
.include   "../dependencies/orix-sdk/macros/SDK_file.mac"

.include   "../libs/usr/arch/include/twil.inc"

.include   "telestrat.inc"
.include   "fcntl.inc"
.include   "cpu.mac"
.include   "errno.inc"

.define TWIL_INTERFACE_NUMBER_OF_RAM_BANK       32
.define TWIL_INTERFACE_NUMBER_OF_CHARS_IN_LABEL 8

    userzp := $80+30

    

    fd_systemd                 := userzp
    buffer                     := userzp+2
    ; Don't use userzp+4 !!! It's a malloc for return routine in twilbank of shell command (when funct + T and funct +L are pressed)
    ptr2                       := userzp+6
    ptr3                       := userzp+8
    sector_to_update_systemd   := userzp+10
    current_bank_systemd       := userzp+11
    save_twil_register         := userzp+12
    save_twil_register_banking := userzp+13
    bank_register              := userzp+14
    current_bank               := userzp+15
    
    ptr4                       := userzp+18
    ptr1                       := userzp+20
    next_bank                  := userzp+22
    loader_tmp1                := userzp+22

.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro

.org $c000

.code
; Entry point
; $c000
    jmp     systemd_start
; $c003
    jmp     _start_twilfirmware
; $c006

    jmp     _loader

_systemd:

.proc systemd_start

    lda     #34 ; Init to bank 33
    sta     next_bank

    print   str_starting,NOSAVE
    print   version,NOSAVE
    print   systemd_starting,NOSAVE

    print   str_reading_banks

    jsr     read_banks
    
    rts
.endproc


.include "commands/firmware/firmware.s"
.include "commands/loader/loader.s"
.include "commands/loader/_start_twilmenubank.s"
.include "strings.asm"


.proc read_banks

    lda      #<path_banks
    ldy      #>path_banks
  
    jsr      open_file

    cpx      #$ff 
    bne      @found
    cmp      #$ff 
    bne      @found
    print    path_banks,NOSAVE
    print    str_not_found,NOSAVE
    rts
@found:
    ; fd_systemd is stored in open_file
    malloc   1000,ptr1,str_oom           ; FIXME
    cpy      #$00
    bne      @continue
    cmp      #$00
    bne      @continue
   
    rts

@continue:
    sta      buffer
    sty      buffer+1
	sta      PTR_READ_DEST
    sta      ptr3   ; for compute
	sty      PTR_READ_DEST+1
    sty      ptr3+1 ; for compute

	lda      #<1000
    ldy      #>1000

	BRK_KERNEL XFREAD
    
    lda      PTR_READ_DEST+1
    sec
    sbc      ptr3+1
    tax
    lda      PTR_READ_DEST
    sec
    sbc      ptr3


    cmp      #$00
    bne      @read_success
    cpx      #$10
    bne      @read_success
    mfree    (buffer)
    fclose   (fd_systemd)    
    print    str_nothing_to_read
    rts

@read_success:

    fclose (fd_systemd)
@again:
    print     str_bank


    jsr      read_inifile_section
    cmp      #$01
    beq      no_chars
    jsr      read_inifile_path
    cmp      #$01
    beq      no_path
    ; Path found, then open
    jsr      load_bank_routine
    jmp      @again


 
no_path:    
    print   str_failed,NOSAVE

no_chars:
    print str_done,NOSAVE
    
    rts
.endproc

.proc load_bank_routine
    fopen  (buffer), O_RDONLY
    cpx     #$FF
    bne     @read ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read ; not null then  start because we did not found a conf

    print   str_failed_word,NOSAVE
    BRK_KERNEL XCRLF 
    print   str_error_path_not_found,NOSAVE
    print   (buffer),NOSAVE
    BRK_KERNEL XCRLF
  ;  mfree (ptr1)     
    
    rts
    
@read:
    sta     fd_systemd    ; Store fd
    stx     fd_systemd+1

    ;Malloc 512 for routine + buffer 16384
    malloc   16896,ptr2,str_oom ; Malloc for the routine to copy into memory, but also the 16KB of the bank to load
    lda      ptr2  ;
    sta      ptr4
    
    ldy      ptr2+1

    iny
    iny

    sty      ptr4+1  ; contains the content of the rom


    fread ptr4, 16384, 1, fd_systemd

    ; copy the routine

    fclose(fd_systemd)



    ldy     #$00
@loop:    
    lda     twil_copy_buffer_to_ram_bank,y
    sta     (ptr2),y
    iny
    bne     @loop

    lda     #$C0
    sta     ptr3+1

    lda     #$00
    sta     ptr3

    lda     next_bank


    jsr     _twil_get_registers_from_id_bank
    stx     sector_to_update_systemd
    sta     current_bank_systemd

    jsr     run
    mfree(ptr2)
    print str_OK,NOSAVE
    BRK_KERNEL XCRLF
    
    ; Checking if all banks are full
    ldx     next_bank
    inx
    cpx     #64
    beq     @error_no_bank_available
    stx     next_bank

    rts
@error_no_bank_available:
    rts

run:
    jmp (ptr2)
.endproc

.define MAX_LINE_SIZE_INI 100
.proc read_inifile_section
    ldy      #$00
@L1:    
    lda      (buffer),y
    cmp      #'['
    beq      @out
    iny
    cpy      #MAX_LINE_SIZE_INI
    bne      @L1
    lda      #$01 ; Not found
    rts

@out:
    iny
    ldx      #$00
;   ***************
@out2:
    lda      (buffer),y
    cmp      #']'
    beq      @out3
    BRK_KERNEL XWR0
   ; sta      current_section,x
    inx
    iny
    cpy      #MAX_LINE_SIZE_INI
    bne      @out2
    lda      #$01 ; Not found
    rts
@out3:
    tya
    clc
    adc      buffer
    bcc      @S5
    inc      buffer+1
@S5:
    sta      buffer

    lda      #$00
    ;sta      current_section
    rts

    lda      #' '
    BRK_KERNEL XWR0 

    ldy      #$00
@L2:    
    lda      (buffer),y
  
    cmp      #$0D
    beq      @out4       
    cmp      #$0A
    beq      @out4
     ;BRK_KERNEL XWR0 
    iny
    bne      @L2
@out4:    
    lda      #$00
    sta      (buffer),y       
    rts
   
.endproc

.proc read_inifile_path
    ldx      #$00
    ldy      #$00
@L1:    
    lda      (buffer),y
    cmp      str_token_path,x
    beq      @out
    cmp      #'='
    beq      @ok
    iny
    cpy      #MAX_LINE_SIZE_INI
    bne      @L1
    lda      #$01 ; Not found
    rts
@out:
    inx
    iny
    bne     @L1
    lda     #$01
    rts
@ok:
    iny  
    tya
    clc
    adc      buffer
    bcc      @S5
    inc      buffer+1
@S5:
    sta      buffer
    
    ;now store 0 at the end of the path
    ldy      #$00
@L6:    
    lda      (buffer),y
    cmp      #$0A
    beq      @out4
    cmp      #$0D
    beq      @out4     
    iny
    bne      @L6
    lda      #$01
    rts

@out4:
        

    lda      #$00    
    sta      (buffer),y
    rts


.endproc


.proc read_modules

    lda      #<path_modules
    ldy      #>path_modules
    jsr      open_file
    cpx      #$FF
    bne      @found
    cmp      #$FF 
    bne      @found
    print   path_modules,NOSAVE
    print   str_not_found,NOSAVE
    rts
@found:    
    fclose (fd_systemd)
    

    ;path_modules
    rts


.endproc


.proc open_file
    sta      ptr2
    sty      ptr2+1
    malloc   100,ptr1,str_oom ; [,oom_msg_ptr] [,fail_value]
    cpy      #$00
    bne      @continue
    cmp      #$00
    bne      @continue

    rts
@continue:
    sta     ptr1
    sty     ptr1+1

    

    ldy  #$00
@loop4:    
@filename:
    lda     (ptr2),y
    beq     @out
    sta     (ptr1),y
    iny
    bne     @loop4
    
@out:
    sta     (ptr1),y
    


    fopen (ptr1), O_RDONLY

    cpx     #$FF
    bne     @read ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read ; not null then  start because we did not found a conf
    print   str_failed,NOSAVE

    
    mfree(ptr1)
    rts
@read:
    sta     fd_systemd
    stx     fd_systemd+1
    
    mfree(ptr1)
    rts
.endproc

.proc twil_copy_buffer_to_ram_bank


	sei

    lda     TWILIGHTE_BANKING_REGISTER
    sta     save_twil_register_banking ; 0

    lda     TWILIGHTE_REGISTER
    sta     save_twil_register  ; A1

    lda     VIA2::PRA
    sta     bank_register ; $01
	; on swappe pour que les banques 8,7,6,5 se retrouvent en bas en id : 1, 2, 3, 4

    lda     VIA2::PRA
    and     #%11111000
    ora     current_bank_systemd
    sta     VIA2::PRA
    

    lda     sector_to_update_systemd ; pour debug FIXME, cela devrait être à 4
    sta  	TWILIGHTE_BANKING_REGISTER

	lda		TWILIGHTE_REGISTER
	ora		#%00100000
	sta		TWILIGHTE_REGISTER



    ldx     #$00
    ldy     #$00
@loop:    
    lda     (ptr4),y
    sta     (ptr3),y
    iny
    bne     @loop
    inc     ptr3+1
    inc     ptr4+1
    inx
    cpx     #64
    bne     @loop
    ; then execute
    ;jsr     $c000

@out:



    lda     bank_register
    sta     VIA2::PRA

    lda     save_twil_register_banking
    sta     TWILIGHTE_BANKING_REGISTER

    lda     save_twil_register
    sta     TWILIGHTE_REGISTER

	lda		#$00
	cli
	rts

.endproc


;unsigned char twil_get_registers_from_id_bank(unsigned char bank);
.proc _twil_get_registers_from_id_bank
    cmp     #$00
    beq     @bank0
    tay
    lda     set,y
    tax
    lda     bank,y
    rts
@bank0:
    ; Impossible to have bank 0
    tax    
    rts
set:
    .byte 0,0,0,0,0,4,4,4
    .byte 1,1,1,1,1,1,1,1
    .byte 1,1,1,1,1,1,1,1
    .byte 1,1,1,1,1,1,1,1

    .byte 0,0,0,0,0,1,1,1
    .byte 1,2,2,2,2,3,3,3
    .byte 3,4,4,4,4,5,5,5
    .byte 5,6,6,6,6,7,7,7,7    

bank:
    .byte 1,1,2,3,4,5,6,7
    .byte 3,1,1,1,1,1,1,1
    .byte 3,1,1,1,1,1,1,1
    .byte 3,1,1,1,1,1,1,1

    .byte 0,1,2,3,4,1,2,3
    .byte 4,1,2,3,4,1,2,3
    .byte 4,1,2,3,4,1,2,3
    .byte 4,1,2,3,4,1,2,3
    .byte 4

.endproc

command0_str:
        .ASCIIZ "systemd"
command1_str:
       .ASCIIZ "twilconf"
commands_text:
commands_address:
commands_version:
        .ASCIIZ "0.0.1"


.res $FFED-*
magic_token_systemd:
        .byte "SYS"
; $fff0
; $00 : empty ROM
; $01 : command ROM
; $02 : TMPFS
; $03 : Drivers
; $04 : filesystem drivers
type_of_rom:
    .byt $01
; $fff1
parse_vector:
        .byt $00,$00
; fff3
adress_commands:
        .addr commands_address   
; fff5        
list_commands:
        .addr command0_str
; $fff7
number_of_commands:
        .byt 1
signature_address:
        .word   rom_signature

; ----------------------------------------------------------------------------
; Version + ROM Type
ROMDEF: 
        .addr systemd_start

; ----------------------------------------------------------------------------
; RESET
rom_reset:
        .addr   systemd_start
; ----------------------------------------------------------------------------
; IRQ Vector
empty_rom_irq_vector:
        .addr   IRQVECTOR ; from telestrat.inc (cc65)

