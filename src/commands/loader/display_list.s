
.proc display_list
    lda     #$00

    sta     id_current_software
    sta     id_current_software+1
    sta     reached_bottom_of_screen


    lda     #$00
    sta     pos_y_listing

    lda     #<(LOADER_FIRST_POSITION_BAR)
    sta     pos_bar
    lda     #>(LOADER_FIRST_POSITION_BAR)
    sta     pos_bar+1

    lda     #<(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3
    lda     #>(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3+1

    lda     ptr2
    sta     ptr1
    lda     ptr2+1
    sta     ptr1+1

    ; Get the number if the softare
    ldy     #LOADER_FIRST_BYTE_OFFSET_AFTER_HEADER ; First byte is the version, second byte and third are the number of software
;@me:
  ;  jmp     @me
    lda     (ptr1),y
    sta     nb_of_software+1
    tax     ; save High for malloc

    dey
    lda     (ptr1),y
    sta     nb_of_software

    asl
    bcc     @do_not_inc_x
    inx
@do_not_inc_x:
    ; At this step we have the number of software*2 for only the first byte
    ; Swap X and Y

    pha
    txa
    asl
    tay
    pla



    ; Now malloc


    BRK_KERNEL XMALLOC
    cmp     #$00
    bne     @not_oom_for_ptr4
    cpy     #$00
    bne     @not_oom_for_ptr4
    mfree(ptr2)
    jsr     exit_interface_confirmed
    print   str_oom
    rts

@not_oom_for_ptr4:


    sta     index_software  ;5041

    sty     index_software+1

    sta     index_software_ptr
    sty     index_software_ptr+1

    ; Id current software used to build the software table
    lda     #$00
    sta     id_current_software
    sta     id_current_software+1

    ; compute ptr1 with the header

    ; Init ptr with the first entry

    lda     ptr1
    clc
    adc     #$03            ; Add 3 because there is 3 bytes in the db header (Db version, number of software : 16 bits)
    bcc     @no_inc_ptr1
    inc     ptr1+1
@no_inc_ptr1:
    sta     ptr1

    ldy     #$00
    lda     ptr1
    sta     (index_software_ptr),y

    iny
    lda     ptr1+1
    sta     (index_software_ptr),y


   ; Inc +2
    inc     index_software_ptr
    bne     @skipinc3
    inc     index_software_ptr+1
@skipinc3:

    inc     index_software_ptr
    bne     @skipinc4
    inc     index_software_ptr+1
@skipinc4:

.endproc

; No rts here please !



.proc start_display


@init_Y:


    ldy     #$00 ; First byte is the version, second byte and third are the number of software
@loop:
    lda     (ptr1),y
    beq     @next_software
    cmp     #$FF ; EOF
    beq     @start_nav
    cmp     #';'
    bne     @inc_y
    jmp     @software_name_found
@inc_y:
    iny
    bne     @loop
@next_software:
    sty     tmp_Y

; Compute ptr
    ldy     tmp_Y
    iny
    tya
    clc
    adc     ptr1
    bcc     @no_compute_inc
    inc     ptr1+1
@no_compute_inc:
    sta     ptr1

    lda     software_index_ptr_compute_from_search
    bne     @init_Y

    ldy     #$00
    lda     ptr1
    sta     (index_software_ptr),y
    iny
    lda     ptr1+1
    sta     (index_software_ptr),y



   ; Inc +2
    inc     index_software_ptr
    bne     @skipinc1
    inc     index_software_ptr+1
@skipinc1:

    inc     index_software_ptr
    bne     @skipinc2
    inc     index_software_ptr+1
@skipinc2:
@skip_compute:


    inc     id_current_software
    bne     @do_not_inc_id_current_software
    inc     id_current_software+1
@do_not_inc_id_current_software:

    jmp     @init_Y

    ; New software

@out:
    rts

@display_information:
    jsr     loader_display_informations
    jmp     @wait_keyboard

@start_nav:
    ; $55FF 784 bytes
    ;jsr     exit_interface_confirmed
    ;jsr     _debug_lsmem

;@me:
    ;jmp     @me

    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar

    lda     loader_from_search_key
    bne     @do_not_init

    lda     #$00
    sta     id_current_software
    sta     id_current_software+1



    lda     index_software
    sta     index_software_ptr

    lda     index_software+1
    sta     index_software_ptr+1
@do_not_init:

@wait_keyboard:
    jsr     debug_loader

    lda     #$00
    sta     loader_from_search_key

    BRK_KERNEL XRDW0
    cmp     #TWIL_KEYBOARD_LEFT
    beq     @exit_listing
    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @exit_listing
    cmp     #TWIL_KEYBOARD_ESC
    beq     @exit_listing
    cmp     #10
    beq     @go_down
    cmp     #11
    beq     @go_up
    cmp     #13
    beq     @go_enter

    cmp     #32
    beq     @display_information


    jsr     loader_search_by_keysearch
    cmp     #$00
    bne     @wait_keyboard

    jmp     start_display



@exit_listing:
    rts
@go_enter:
    jmp     _loader_launch_software
@go_down:
    ; compute if we reached the number of software
    ;nb_of_software

    jmp     @go_down_routine


@go_up:
    jmp     @go_up_routine

@software_name_found:
    iny
    tya
    clc
    adc     ptr1
    bcc     @S1
    inc     ptr1+1
@S1:
    sta     ptr1

    ldy     #$00
@loop2:

    lda     (ptr1),y
    cmp     #LOADER_CONF_SEPARATOR ; Is it ';' ?
    beq     @exit

    ldx     reached_bottom_of_screen
    cpx     #LOADER_LAST_LINE_MENU_ITEM
    beq     @no_display_software
    cpy     #LOADER_MAX_LENGTH_SOFTWARE_NAME ; FIXME
    bcs     @no_display_software

    sta     (ptr3),y
@no_display_software:
    iny
    bne     @loop2


@exit:
    ; skip flags

    lda     ptr3
    clc
    adc     #$28
    bcc     @S13
    inc     ptr3+1
@S13:
    sta     ptr3

@L20:

    iny
    lda     (ptr1),y

    beq     @end_of_software_line

    bne     @L20

@end_of_software_line:
    lda     reached_bottom_of_screen
    cmp     #LOADER_LAST_LINE_MENU_ITEM
    beq     @skip_inc_reached_bottom_of_screen
    inc     reached_bottom_of_screen
@skip_inc_reached_bottom_of_screen:


@do_not_inc:

    jmp     @loop

@go_down_routine:
    jsr     loader_check_max_software
    jmp     @wait_keyboard

@go_up_routine:
    ; Does the bar is at the first line ?



@check_pos:
    lda     pos_y_listing
    beq     @skip_bar
    lda     #$10
    jsr     loader_display_bar

    dec     pos_y_listing
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar

; 70e9
; Inc +2
    lda     index_software_ptr
    bne     @skipinc1_up
    dec     index_software_ptr+1
@skipinc1_up:
    dec     index_software_ptr

    lda     index_software_ptr
    bne     @skipinc2_up
    dec     index_software_ptr+1
@skipinc2_up:
    dec     index_software_ptr


    lda     id_current_software
    bne     @skip_dec_high
    dec     id_current_software+1
@skip_dec_high:
    dec     id_current_software


@skip_bar:
    lda     pos_y_listing
    bne     @exit_up

    lda     id_current_software+1
    beq     @check_id_0_software
    jmp     @doscroll

@check_id_0_software:
    lda     id_current_software
    beq     @exit_up

    ;; No it's not the first software in the db, do scroll now
@doscroll:
    lda     #$10
    jsr     loader_display_bar


    jsr     doscrolldowninframe
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar


    lda     id_current_software
    bne     @skip_dec_high3
    dec     id_current_software+1
@skip_dec_high3:
    dec     id_current_software



   ; dec -2
    lda     index_software_ptr
    bne     @do_not_inc_ptr_high
    dec     index_software_ptr+1
@do_not_inc_ptr_high:
    dec     index_software_ptr

    lda     index_software_ptr
    bne     @do_not_inc_ptr_high2
    dec     index_software_ptr+1
@do_not_inc_ptr_high2:
    dec     index_software_ptr



    jsr     loader_display_software
    jmp     @exit_up


@dec_id_current_software:
    lda     id_current_software
    bne     @skip_dec_high2
    dec     id_current_software+1
@skip_dec_high2:
    dec     id_current_software
@exit_up:
    jmp     @wait_keyboard
.endproc
