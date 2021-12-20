
.define MENU_BANK_LOADER    $01
.define BANK_BAR_COLOR      $11

.define MAX_BANK_TO_DISPLAY 20

BANK_LABEL=($BB80+40*7+2)

.proc _start_twilmenubank

    lda     #$00
    sta     line_number

    lda     #$00
    sta     pos_y_bar

    lda     #<BANK_LABEL
    sta     ptr4
    
    lda     #<(BANK_LABEL-1)
    sta     @__store_bar+1

    lda     #>BANK_LABEL
    sta     ptr4+1

    lda     #>(BANK_LABEL-1)
    sta     @__store_bar+2
    

    lda     #$00
    sta     number_of_roms_in_banks_cnf

    jsr     read_banks_bank_launcher

    jsr     @display_bar
@read_keyboard:
    BRK_TELEMON XRDW0            ; read keyboard
    asl     KBDCTC
    bcc     @checkkey
@exit:
    pha     ; Save key
    mfree(ptr1)
    pla
    rts

@checkkey:
    cmp     #27
    beq     @exit
    cmp     #$09
    beq     @exit

    cmp     #13
    beq     @go_enter
    cmp     #10
    beq     @go_down
    cmp     #11
    beq     @go_up
    jmp     @read_keyboard
  


@go_enter:
    jsr     _missing_file
    ldx     pos_y_bar
    lda     tab_path_bank_low,x
    sta     ptr1
    lda     tab_path_bank_high,x
    sta     ptr1+1
    jmp     load_bank_routine_menu_bank    
    
    

@go_down:
    lda     pos_y_bar
    cmp     number_of_roms_in_banks_cnf
    beq     @read_keyboard
    jsr     @erase_bar
@do_not_erase_bar:   
    inc     pos_y_bar
    lda     @__store_bar+1
    clc     
    adc     #$28
    bcc     @S_DOWN
    inc     @__store_bar+2
@S_DOWN:
    sta     @__store_bar+1
    jsr     @display_bar    
    jmp     @read_keyboard

@go_up:
    lda     pos_y_bar
    beq     @do_not_go_up
    jsr     @erase_bar
  
    dec     pos_y_bar


    lda     @__store_bar+1
    sec     
    sbc     #$28
    bcs     @S_UP
    dec     @__store_bar+2
@S_UP:
    sta     @__store_bar+1
    jsr     @display_bar 
@do_not_go_up:       
    jmp     @read_keyboard


@display_bar:
    lda     #BANK_BAR_COLOR
    bne     @__store_bar
@erase_bar:    
    lda     #' '
    bne     @__store_bar
@__store_bar:    
    sta     BANK_LABEL-1
    rts

.endproc

.proc load_bank_routine_menu_bank
    fopen  (ptr1), O_RDONLY
    cpx     #$FF
    bne     @read ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read ; not null then  start because we did not found a conf
    jsr     _missing_file
    print   str_failed_word,NOSAVE
    BRK_KERNEL XCRLF 
    print   str_error_path_not_found
    print   (ptr1)
    BRK_KERNEL XCRLF
    rts
    
@read:
    sta     fd_systemd
    stx     fd_systemd+1



    ;Malloc 512 for routine + buffer 16384
    malloc   16896,ptr2,str_oom ; Malloc for the routine to copy into memory, but also the 16KB of the bank to load
    lda      ptr2  ;
    sta      ptr4
    sta      PTR_READ_DEST
    
    ldy      ptr2+1

    iny
    iny
    sty      PTR_READ_DEST+1
    sty      ptr4+1  ; contains the content of the rom

    ; We read the file with the correct
    lda     #<16384
    ldy     #>16384

    ; reads byte 
    BRK_KERNEL XFREAD

    ; copy the routine

    fclose(fd_systemd)

    ldy     #$00
@loop:    
    lda     bank_twil_copy_buffer_to_ram_bank,y
    sta     (ptr2),y
    iny
    bne     @loop
    
    ; We set dest ptr (ROM)
    lda     #$C0
    sta     ptr3+1

    lda     #$00
    sta     ptr3

    jmp     run

run:
    jmp    (ptr2)
.endproc


.proc bank_twil_copy_buffer_to_ram_bank
	sei
    ; Switch to bank 0
    lda     VIA2::PRA
    and     #%11111000
    sta     VIA2::PRA
    ; Copy ROM loaded into bank 0
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

    lda     #%01111111
    sta     $30E

    lda     $FFFC
    sta     $00
    lda     $FFFD
    sta     $01

    jmp     ($0000)
.endproc


.proc _missing_file
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE

    rts
.endproc

.proc read_banks_bank_launcher

    lda      #<path_banks
    ldy      #>path_banks
  
    jsr      open_file

    cpx      #$FF 
    bne      @found
    cmp      #$FF 
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
    mfree    (ptr1)

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
    ;print     str_bank


    jsr      read_inifile_section_bank_launcher
    cmp      #$01
    beq      no_chars
    jsr      read_inifile_path_bank_launcher
    cmp      #$01
    beq      no_path
    ; Path found, then open
    
    jmp      @again


 
no_path:   
    ;jsr     _missing_file
    ;print   str_path_is_missing,NOSAVE
    ;lda     line_number
    ;ldx     #$02
    ;stx     DEFAFF
    ;ldy     #$00
    ;BRK_KERNEL XDECIM
    ;lda     #$01 ; error
    ;rts
    ;print   str_failed,NOSAVE

no_chars:
   ; print str_done,NOSAVE
    dec     number_of_roms_in_banks_cnf
        lda     #$01 ; error
    rts
.endproc


.proc read_inifile_section_bank_launcher
MAX_LINE_SIZE_INI=100

    ldy      #$00
@L1:    
    lda      (buffer),y
    cmp      #'['
    beq      @out
    cmp      #$0D
    bne      @continue
    inc      line_number
    jmp      @continue
    cmp      #$0A
    bne      @continue
    
    inc      line_number
@continue:    
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
    sta      saveA
    sty      saveY
    txa
    tay
    lda      saveA
    sta      (ptr4),y
    ldy      saveY
  ;  BRK_KERNEL XWR0
   ; sta     BANK_LABEL,x
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

    lda      ptr4
    clc
    adc      #$28
    bcc      @S6
    inc      ptr4+1
@S6:
    sta      ptr4
    inc      number_of_roms_in_banks_cnf

    lda      #$00
    ;sta      current_section
    rts

    ldy      #$00
@L2:    
    lda      (buffer),y
  
    cmp      #$0D
    beq      @out4       
    cmp      #$0A
    beq      @out4
    inc      line_number

    iny
    bne      @L2
@out4:    
    lda      #$00
    sta      (buffer),y       
    rts

.endproc

.proc read_inifile_path_bank_launcher
MAX_LINE_SIZE_INI=100


    ldx      #$00
    ldy      #$00
@L1:    
    lda      (buffer),y
    cmp      str_token_path_bank_menu,x ; We reach path ? yes
    beq      @out
    cmp      #'=' ; We reach '=' It means that it's rom 
    beq      @path_found
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
@path_found:
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

    lda      #$01 ; We reach a length of 256 chars for the path, we generate an error
    rts

@out4:
        

    lda      #$00    
    sta      (buffer),y

    ; Now store to buffer
    ldx      number_of_roms_in_banks_cnf
    dex      ; Because it's incremented before
    lda      buffer
    sta      tab_path_bank_low,x
    lda      buffer+1
    sta      tab_path_bank_high,x

    rts


.endproc

tab_path_bank_low:
    .res MAX_BANK_TO_DISPLAY
tab_path_bank_high:
    .res MAX_BANK_TO_DISPLAY    
number_of_roms_in_banks_cnf:
    .res 1

str_path_is_missing:
    .asciiz "file is missing in /etc/systemd/banks.cnf line : "

str_token_path_bank_menu:
    .asciiz "file"   
saveY:
    .res     1
saveX:
    .res     1
saveA:
    .res     1
pos_y_bar: 
    .res 1
line_number:
    .res 1    