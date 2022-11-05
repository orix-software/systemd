.proc twil_interface_init
    stx     save
    ; restore chars
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE

    lda     #$00
    sta     twil_interface_current_menu

    lda     verticalBorder
    sta     46080+8*96
    sta     46080+8*96+1
    sta     46080+8*96+2
    sta     46080+8*96+3
    sta     46080+8*96+4
    sta     46080+8*96+5
    sta     46080+8*96+6
    sta     46080+8*96+7

    lda     #$07
    ldx     #$00
@clear:
    sta     $a000,x
    sta     $a000+256,x
    sta     $a000+512,x
    sta     $a000+512+256,x
    sta     $a000+1024,x
    sta     $a000+1024+256,x
    sta     $a000+1024+512,x
    sta     $a000+1024+512+256,x
    sta     $a000+2048,x
    inx
    bne     @clear

    lda     #30
    sta     $BB80
    sta     $bb80+40

    lda     #26
    sta     $A000+40*55

    ldx     save
    jsr     _displayTwilighteBanner
    jsr     _displayFrame


    lda     #$00
    jsr     twil_interface_change_menu

    rts
save:
    .res    1
.endproc
