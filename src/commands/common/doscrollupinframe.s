.proc doscrollupinframe
    ldx     #$07
    ldy     #24
    BRK_KERNEL XSCROH
    lda     #FRAME_VERTICAL_BAR_CHAR
    sta     TWIL_INTERFACE_LAST_LINE_TEXT-40
    sta     TWIL_INTERFACE_LAST_LINE_TEXT-1
    rts
.endproc
