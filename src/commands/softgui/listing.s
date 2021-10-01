.proc listing

  ;  jsr     basic11_read_main_dbfile FIXME
    cmp     #$FF
    bne     @continuegui
    cpx     #$FF
    bne     @continuegui
   ; PRINT   str_basic11_missing ; FIXME
    rts

@continuegui:
    ; save fp
   rts 
   ; jmp     basic11_start_gui FIXME
.endproc   