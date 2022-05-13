.proc loader_display_informations
    rts
    lda     #$11
    sta     $bb80
    jmp     loader_display_informations
    rts
.endproc
