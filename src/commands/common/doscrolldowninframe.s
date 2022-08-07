.proc doscrolldowninframe
    ldx     #$07
    ldy     #24
    BRK_KERNEL XSCROB
    lda     #FRAME_VERTICAL_BAR_CHAR
    sta     TWIL_INTERFACE_FIRST_LINE_TEXT
    sta     TWIL_INTERFACE_FIRST_LINE_TEXT+39
    rts
.endproc
