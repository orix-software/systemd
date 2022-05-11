.proc loader_search_by_keysearch


    ; User press key a to z
    cmp     #'a' ; 'a'
    bcc     @check_numbers
    cmp     #'z'+1 ; 'z'
    bcs     @check_numbers
    ; a to Z are pressed
    ; Switch to uppercase and seartch
    sbc     #$1F
    jmp     @search

@check_numbers:
    ; User press key 0 to 9
    cmp     #'0'
    bcc     @exit

    cmp     #'9'+1
    bcs     @exit


@search:

;:index_software_ptr

    sta     tmp1 ; Save the key pressed

    lda     #$00
    sta     @compute_number_of_software
    lda     #$00
    sta     @compute_number_of_software+1

    lda     index_software
    sta     index_software_ptr

    lda     index_software+1
    sta     index_software_ptr+1


    lda     ptr2
    sta     ptr1

    lda     ptr2+1
    sta     ptr1+1

    ldy     #LOADER_FIRST_BYTE_OFFSET_AFTER_HEADER
@restart:

    iny
@L1:
    lda     (ptr1),y
    cmp     #$FF ; EOF reached ?
    beq     @exit
    cmp     #';'
    bne     @restart
    iny
;$0ca2
    lda     (ptr1),y
    cmp     #$FF ; EOF reached ?
    beq     @exit
    cmp     tmp1
    beq     @keyfound
@search_0:

    iny
    ; Looking for 0
    lda     (ptr1),y
    beq     @next_software_reached
    cmp     #$FF
    beq     @exit
    bne     @search_0
@next_software_reached:
    inc     @compute_number_of_software
    bne     @skip_inc_high
    inc     @compute_number_of_software+1
@skip_inc_high:
   ; Inc +2
    inc     index_software_ptr
    bne     @skipinc1
    inc     index_software_ptr+1
@skipinc1:

    inc     index_software_ptr
    bne     @skipinc2
    inc     index_software_ptr+1
@skipinc2:


    ;iny
    jsr     @compute_offset
    ldy     #$00
    jmp     @restart

@exit:

    lda     #$00
    sta     loader_from_search_key

    lda     index_software
    sta     index_software_ptr

    lda     index_software+1
    sta     index_software_ptr+1

    lda     #$01 ; Not founds
    rts

@compute_number_of_software:
    .res 2

@keyfound:

    lda     #$01
    sta     loader_from_search_key


    jsr     twil_interface_clear_menu
    ldy     #$00

    ldy     #$00
    lda     ptr1

    iny
    lda     ptr1+1


    lda     #$00
    sta     reached_bottom_of_screen

    lda     #<(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3
    lda     #>(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3+1

    lda     #$00
    sta     pos_y_listing

    lda     @compute_number_of_software
    sta     id_current_software

    lda     @compute_number_of_software+1
    sta     id_current_software+1

    lda     #$01
    sta     software_index_ptr_compute_from_search

    lda     #$00 ; Found
    rts

@compute_offset:
    tya
    clc
    adc     ptr1
    bcc     @do_not_inc
    inc     ptr1+1
@do_not_inc:
    sta     ptr1
    rts
.endproc

