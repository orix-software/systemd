.define TWIL_COLOR_MENU_SELECTED   $06
.define TWIL_COLOR_MENU_UNSELECTED $07

; A=0 menu is set to the right color

.proc twil_interface_change_menu

    cmp     #$00
    bne     @off

    lda     #TWIL_COLOR_MENU_SELECTED
    sta     value_on

    lda     #TWIL_COLOR_MENU_UNSELECTED
    sta     value_off
    jmp     @begin
@off:

    lda     #$07
    sta     value_on

    lda     #$06
    sta     value_off

@begin:
    ldx     twil_interface_current_menu

    lda     icons_list_pos_high,x
    sta     __pos+2
    sta     __pos2+2

    lda     icons_list_pos_low,x
    sta     __pos+1
    sta     __pos2+1

    bne     @do_not_dec

    dec     __pos+2
    dec     __pos2+2

@do_not_dec:
    dec     __pos+1
    dec     __pos2+1


    ldy     #$06
    ldx     #26
L1:
    lda     value_on
__pos:
    sta     $A000
    lda     value_off
__pos2:
    sta     $A000,y

    lda     __pos+1
    clc
    adc     #$28
    bcc     @S1
    inc     __pos+2
    inc     __pos2+2
@S1:
    sta     __pos+1
    sta     __pos2+1
    dex
    bpl     L1
    rts
value_on:
    .res    1
value_off:
    .res    1
.endproc
