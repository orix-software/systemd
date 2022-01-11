.proc   _loader_clear_bottom_text
    lda     #<(LOADER_POS_INF_NUMBER)
    sta     TR5
    lda     #>(LOADER_POS_INF_NUMBER)
    sta     TR5+1

    lda     #' '
    ldy     #$00
@loop:    
    sta     (TR5),y
    iny
    cpy     #39
    bne     @loop

    rts
.endproc

