
.define MENU_BANK_LOADER    $01
.define BANK_BAR_COLOR      $11



BANK_LABEL=($BB80+40*7+2)

.define MENU_ROM_LAUNCH_MAX_FILESIZE 6000 ; Max file size of banks.cnf
.define MENU_ROM_LAUNCH_MAX_LINEZIZE 100 ; Max Line when we try to parse  [Label] or path=, if it's longer the string is skipped
.define MENU_ROM_MAX_LINE_LABEL      37  ; Max length of the label displayed on screen

.proc _start_twilmenubank
    jsr     _loader_clear_bottom_text ; Clear bottom text

    lda     #$00
    sta     pos_y_on_screen
    sta     skip_display
    sta     nb_of_max_pos_y
    sta     go_up

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
    sta     number_of_roms_in_banks_cnf+1

    jsr     read_banks_bank_launcher
    cpx     #$FF
    bne     @banks_cnf_present
    cmp     #$FF
    bne     @banks_cnf_present
    lda     #$01
    rts
@banks_cnf_present:

    jsr     @display_bar

    jsr     debug_loader_rom

    jsr     seek_label_next

@read_keyboard:
    BRK_TELEMON XRDW0            ; read keyboard
    asl     KBDCTC
    bcc     @checkkey
@exit:
    pha     ; Save key
    jsr     _menubanks_clean_exit
    mfree(ptr1)
    pla
    rts


@checkkey:
    cmp     #TWIL_KEYBOARD_ESC
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


    lda     ptr_current_path
    sta     ptr1
    lda     ptr_current_path+1
    sta     ptr1+1


    ; FIXME PATH
    jsr     load_bank_routine_menu_bank

    lda     #$01 ; Error
    jmp     @exit


@go_down:
    lda     pos_y_bar
    clc
    adc     #$01
    cmp     number_of_roms_in_banks_cnf
    beq     @read_keyboard

    lda     pos_y_on_screen
    cmp     #17

    bne     @continue_go_down

    jsr     @erase_bar

    jsr     doscrollupinframe


    jsr     seek_label_next

    lda     ptr_current_label
    sta     RES
    lda     ptr_current_label+1
    sta     RES+1

    ldy     #$00
@loop300:
    lda     (RES),y
    cmp     #$ff
    beq     @continue_down_check
    cmp     #']'
    beq     @continue_down_check
    sta     $bb80+40*24+2,y
@continue300:
    iny
    cpy     #MENU_ROM_MAX_LINE_LABEL
    beq     @continue_down_check
    bne     @loop300
@continue_down_check:
    inc     pos_y_bar


    jsr     @display_bar_and_display_infos
    jmp     @read_keyboard

@continue_go_down:

    jsr     seek_label_next
    inc     pos_y_on_screen
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

    jsr     @display_bar_and_display_infos

    jmp     @read_keyboard

@go_up:


@do_not_update:

    lda     pos_y_on_screen
    beq     @check_if_first_rom
    jsr     @erase_bar
    dec     pos_y_on_screen
    dec     pos_y_bar


    lda     @__store_bar+1
    sec
    sbc     #$28
    bcs     @S_UP
    dec     @__store_bar+2
@S_UP:
    sta     @__store_bar+1

    jsr     @display_bar
    jsr     debug_loader_rom
    jsr     seek_label_before
@do_not_go_up:
    jmp     @read_keyboard

@check_if_first_rom:
    lda     pos_y_bar
    cmp     #$00
    beq     @no_scroll_up

    jsr     @erase_bar

    jsr     doscrolldowninframe

    jsr     seek_label_before


    lda     ptr_current_label
    sta     RES
    lda     ptr_current_label+1
    sta     RES+1

    ldy     #$00
@loop301:
    lda     (RES),y
    cmp     #']'
    beq     @continue_up_check
    sta     $bb80+40*7+2,y
@continue301:
    iny
    cpy     #MENU_ROM_MAX_LINE_LABEL
    beq     @continue_up_check
    bne     @loop301



@continue_up_check:
    dec     pos_y_bar
    jsr     @display_bar_and_display_infos


@no_scroll_up:
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

@display_bar_and_display_infos:
    jsr     @display_bar
    jsr     debug_loader_rom
    rts
.endproc

.proc load_bank_routine_menu_bank
    fopen  (ptr1), O_RDONLY
    cpx     #$FF
    bne     @read ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read ; not null then  start because we did not found a conf
    jsr     _missing_file
    print   str_failed_word
    crlf
    print   str_error_path_not_found
    print   (ptr1)
    crlf

    lda     #$01 ; Error
    rts

@read:
    sta     fd_systemd
    stx     fd_systemd+1



    ;Malloc 512 for routine + buffer 16384
    malloc   16896,ptr2,str_oom ; Malloc for the routine to copy into memory, but also the 16KB of the bank to load
    lda     ptr2  ;
    sta     ptr4
    sta     PTR_READ_DEST

    ldy     ptr2+1

    iny
    iny
    sty     PTR_READ_DEST+1
    sty     ptr4+1  ; contains the content of the rom

    ; We read the file with the correct


    fread (PTR_READ_DEST), 16384, 1, fd_systemd

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
	BRK_KERNEL XSCRNE ; Reload charset ?
    rts
.endproc

.proc _menubanks_clean_exit
    lda     buffer_bkp
    ldy     buffer_bkp+1
    BRK_KERNEL XFREE
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
     jsr      _missing_file
    print    path_banks
    lda      #' '
    BRK_KERNEL XWR0
    print    str_not_found
    crlf
    lda      #$FF
    tax
    rts
@found:
    ; Save FP
    sta     fp_banks_cnf
    stx     fp_banks_cnf+1

    ; fd_systemd is stored in open_file
    malloc   MENU_ROM_LAUNCH_MAX_FILESIZE,ptr1,str_oom           ; FIXME
    cpy      #$00
    bne      @continue
    cmp      #$00
    bne      @continue
    mfree    (ptr1)

    rts

@continue:
    sta      buffer
    sta      buffer_bkp
    sta      ptr3
    sty      buffer+1
    sty      buffer_bkp+1
    sty      ptr3+1
	sta      PTR_READ_DEST
	sty      PTR_READ_DEST+1

    fread (PTR_READ_DEST), MENU_ROM_LAUNCH_MAX_FILESIZE, 1, fp_banks_cnf ; myptr is from a malloc for example

    ; Do we read 0 bytes ?
    cmp      #$00
    bne      @read_success
    cpx      #$00           ;
    bne      @read_success
    mfree    (buffer)
    fclose   (fd_systemd)
    print    str_nothing_to_read
    rts

@read_success:

    ; Compute the bytes : return of fread

    lda      PTR_READ_DEST+1 ; 0C7E-0AA4
    sec
    sbc      ptr3+1
    sta      ptr3+1


    lda      PTR_READ_DEST ; 7E

    sec
    sbc      ptr3
    bcs      @nodecX
    dec      ptr3+1
@nodecX:
    sta      ptr3   ; save length read
;    stx      ptr3+1 ; for compute
    fclose (fd_systemd)
    ; Store $FF of EOF at the end

    ; Compute the end of the file to store $ff in the last byte
    lda      buffer+1
    clc
    adc      ptr3+1
    sta      ptr3+1

    lda      buffer
    clc
    adc      ptr3

    bcc      @skip_inc
    inc      ptr3+1
@skip_inc:
    sta      ptr3
    sta      @store_me+1

    lda      ptr3+1
    sta      @store_me+2

    ; Theses lines does the step at the end of the memory of banks.cnf : \0,$FF (Because last entry of path= has no \0 in this case, and $FF is used to detect EOF)
    ldx      #$00
    lda      #$00
@store_me:
    sta      $dead,x      ; Store $ff
    lda      #$FF
    inx
    cpx      #$02
    bne      @store_me

@again:
    ; ptr_current_label contains the first entry of banks.cnf
    lda      buffer_bkp
    sta      ptr_current_label

    lda      buffer_bkp+1
    sta      ptr_current_label+1

    jsr      seek_path

    jsr      read_inifile_section_bank_launcher
    cmp      #$01
    beq      no_chars

    jsr      read_inifile_path_bank_launcher
    cmp      #$01
    beq      no_path
    ; Path found, then open

    jmp      @again

no_path:


no_chars:
    lda     #$01 ; error
    rts
.endproc

.proc seek_path
    lda      ptr_current_label
    sta      RES
    sta      ptr_current_path

    lda      ptr_current_label+1
    sta      ptr_current_path+1
    sta      RES+1

    ; Looking for =
    ldy      #$00
@loop200:
    lda      (RES),y
    cmp      #'='
    beq      @exit
    iny
    bne      @loop200
@exit:
    ; = found
    iny
    tya
    clc
    adc      ptr_current_path
    bcc      @skip_inc_200
    inc      ptr_current_path+1
@skip_inc_200:
    sta      ptr_current_path

    rts
.endproc

.proc seek_label_next
    lda      ptr_current_label
    sta      RES
    lda      ptr_current_label+1
    sta      RES+1


    ; Looking for =
    ldy      #$01
@loop200:
    lda      (RES),y
    cmp      #'['
    beq      @found
    iny
    bne      @loop200
@found:
    ; = found
    iny
    tya
    clc
    adc      ptr_current_label
    bcc      @skip_inc_200
    inc      ptr_current_label+1
@skip_inc_200:
    sta      ptr_current_label
    jsr      seek_path

    rts
.endproc


.proc seek_label_before

    lda      ptr_current_label+1
    sta      RES+1

    lda      ptr_current_label
    sec
    sbc      #$02
    bcs      @do_not_dec
    dec      RES+1
@do_not_dec:
    sta      RES

    ; Looking for =
    ldy      #$00
@loop200:
    lda      (RES),y
    cmp      #'['
    beq      @found
    dec      RES
    bne      @skip
    dec      RES+1
@skip:
    bne      @loop200
@found:
    ; = found

    lda     RES+1
    sta     ptr_current_label+1

    lda     RES
    clc
    adc     #$01
    bcc     @skip2
    dec     ptr_current_label+1
@skip2:
    sta     ptr_current_label

    jsr     seek_path

    rts
.endproc


.proc read_inifile_section_bank_launcher


    ldy      #$00
@L1:
    lda      (buffer),y
    cmp      #'['
    beq      @out
    cmp      #$FF
    beq      @exit_read_label
    cmp      #$0D
    bne      @continue

    jmp      @continue
    cmp      #$0A
    bne      @continue
    ; error

@continue:
    iny
    cpy      #MENU_ROM_LAUNCH_MAX_LINEZIZE
    bne      @L1
@exit_read_label:

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

    cpx      #MENU_ROM_MAX_LINE_LABEL
    bcs      @skip_display_label

    txa
    tay

    lda      skip_display
    bne      @skip_display_label

    lda      saveA
    sta      (ptr4),y       ; Store to screen
@skip_display_label:
    ldy      saveY

    inx
    iny
    cpy      #MENU_ROM_LAUNCH_MAX_LINEZIZE
    bne      @out2
    lda      #$01 ; Not found
    rts
@out3:

    inc      number_of_roms_in_banks_cnf
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



    lda      nb_of_max_pos_y
    cmp      #17
    bne      @skip_bottom_page

    lda      #$01
    sta      skip_display
    bne      @exit_manage_display

@skip_bottom_page:
    inc      nb_of_max_pos_y


@exit_manage_display:

    lda      #$00
    rts

    ldy      #$00
@L2:
    lda      (buffer),y

    cmp      #$0D
    beq      @out4
    cmp      #$0A
    beq      @out4


    iny
    bne      @L2
@out4:
    lda      #$00
    sta      (buffer),y
    rts

.endproc

.proc read_inifile_path_bank_launcher

    ldx      #$00
    ldy      #$00
@L1:
    lda      (buffer),y

    cmp      #'=' ; We reach '=' It means that it's rom
    beq      @path_found
    iny
    cpy      #MENU_ROM_LAUNCH_MAX_LINEZIZE
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

    rts

.endproc


.proc debug_loader_rom

    lda     #<(LOADER_POS_INF_NUMBER)
    sta     TR5
    lda     #>(LOADER_POS_INF_NUMBER)
    sta     TR5+1

    lda     #$20
    sta     DEFAFF

    ldx     #$01
    ldy     #$00

    lda     pos_y_bar
    clc
    adc     #$01
    bcc     @S1
    iny
@S1:
    BRK_KERNEL XBINDX

    lda     #'/'
    sta     LOADER_POS_INF_NUMBER+3

    lda     #<(LOADER_POS_INF_NUMBER+4)
    sta     TR5
    lda     #>(LOADER_POS_INF_NUMBER+4)
    sta     TR5+1

    lda     #$20
    sta     DEFAFF

    ldx     #$01
    ldy     number_of_roms_in_banks_cnf+1
    lda     number_of_roms_in_banks_cnf
    BRK_KERNEL XBINDX
    rts
.endproc

number_of_roms_in_banks_cnf:
    .res     2
saveY:
    .res     1
saveX:
    .res     1
saveA:
    .res     1
pos_y_bar:
    .res     1
pos_y_on_screen:
    .res     1
fp_banks_cnf:
    .res     2
buffer_bkp:
    .res     2
skip_display:
    .byte    0
nb_of_max_pos_y:
    .byte    0
ptr_current_label:
    .res     2
ptr_current_path:
    .res     2
go_up:
    .res     1

