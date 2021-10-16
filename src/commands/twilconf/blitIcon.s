



ptr_pos_img_src := userzp ; 2
ptr_pos_img_dest := userzp+2 ; 2

.proc _blitIcon


    lda     icons_list_low,x
    sta     ptr_pos_img_src
    lda     icons_list_high,x
    sta     ptr_pos_img_src+1

    lda     icons_list_pos_low,x
    sta     ptr_pos_img_dest
    lda     icons_list_pos_high,x
    sta     ptr_pos_img_dest+1    


    ldx     #$00
@next_line:
    ldy     #$00
@L1:    
    lda     (ptr_pos_img_src),y
    sta     (ptr_pos_img_dest),y
    iny
    cpy     #$05
    bne     @L1

    lda     ptr_pos_img_src
    clc 
    adc     #$05
    bcc     @no_inc
    inc     ptr_pos_img_src+1
@no_inc:
    sta     ptr_pos_img_src

    lda     ptr_pos_img_dest
    clc 
    adc     #$28
    bcc     @no_inc2
    inc     ptr_pos_img_dest+1
@no_inc2:
    sta     ptr_pos_img_dest


    inx
    cpx     #24
    bne     @next_line

    rts
.endproc

POSY_ICON=20

icons_list_pos_low:
    .byte <($a000+POSY_ICON*40+1) ; Infos Firmware 2 & 3
    .byte <($a000+POSY_ICON*40+7)    
    .byte <($a000+POSY_ICON*40+13)
    .byte <($a000+POSY_ICON*40+1)
    .byte <($a000+POSY_ICON*40+7)    
    .byte <($a000+POSY_ICON*40+13)
    .byte <($a000+POSY_ICON*40+20)
    .byte <($a000+POSY_ICON*40+7) ;  exit firm 2
    .byte <($a000+POSY_ICON*40+7)  ; Network firm v3
    .byte <($a000+POSY_ICON*40+25) ; Exit firm v3
    .byte <($a000+POSY_ICON*40+19) ; clock (firm3)
    .byte <($a000+POSY_ICON*40+1)  ; Rom for launcher
    .byte <($a000+POSY_ICON*40+7)  ; exit launcher
    
icons_list_pos_high:
    .byte >($a000+POSY_ICON*40+1)  ; 0 Infos
    .byte >($a000+POSY_ICON*40+7)  ; 1  
    .byte >($a000+POSY_ICON*40+13) ; 2
    .byte >($a000+POSY_ICON*40+1)  ; 3
    .byte >($a000+POSY_ICON*40+7)  ; 4  
    .byte >($a000+POSY_ICON*40+13) ; 5
    .byte >($a000+POSY_ICON*40+20) ; 6
    .byte >($a000+POSY_ICON*40+7) ; 7 Exit firm 2
    .byte >($a000+POSY_ICON*40+7)  ; 8 Network
    .byte >($a000+POSY_ICON*40+25) ; 9 Exit firm v3
    .byte >($a000+POSY_ICON*40+19) ; $0A   ; clock (firm3)
    .byte >($a000+POSY_ICON*40+1)  ; $0B Rom for launcher
    .byte >($a000+POSY_ICON*40+7)  ; $0C Exit launcher

icons_list_low:
    .byte <info_icon        ; 0
    .byte <chip_icon        ; 1    
    .byte <reload_chip_icon ; 2
    .byte <joy_icon         ; 3
    .byte <demo_icon        ; 4
    .byte <tools_icon       ; 5
    .byte <command_icon     ; 6
    .byte <exit_icon        ; 7
    .byte <network_icon     ; 8 
    .byte <exit_icon        ; 9
    .byte <clock_icon       ; $0A
    .byte <chip_icon        ; $0B    
    .byte <exit_icon        ; $0C
    
icons_list_high:    
    .byte >info_icon
    .byte >chip_icon    
    .byte >reload_chip_icon
    .byte >joy_icon    
    .byte >demo_icon
    .byte >tools_icon    
    .byte >command_icon
    .byte >exit_icon
    .byte >network_icon 
    .byte >exit_icon 
    .byte >clock_icon 
    .byte >chip_icon            
    .byte >exit_icon 

reload_chip_icon:
.byt $40,$5C,$40,$40,$40
.byt $41,$7F,$40,$40,$40
.byt $43,$63,$60,$40,$40
.byt $43,$41,$60,$40,$40
.byt $46,$40,$70,$58,$40
.byt $46,$44,$71,$66,$40
.byt $46,$46,$76,$41,$60
.byt $43,$47,$70,$40,$58
.byt $43,$67,$60,$41,$68
.byt $41,$47,$70,$46,$48
.byt $40,$47,$78,$58,$68
.byt $41,$40,$41,$60,$78
.byt $46,$40,$46,$49,$70
.byt $47,$40,$58,$4E,$58
.byt $47,$71,$62,$5C,$48
.byt $47,$7E,$43,$66,$48
.byt $47,$7C,$67,$42,$40
.byt $41,$7C,$79,$62,$40
.byt $40,$5D,$70,$60,$40
.byt $40,$46,$58,$60,$40
.byt $40,$40,$48,$40,$40
.byt $40,$40,$48,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40

chip_in_icon:
.byt $40,$5F,$40,$40,$40
.byt $40,$51,$40,$40,$40
.byt $40,$51,$40,$40,$40
.byt $40,$51,$40,$40,$40
.byt $41,$71,$73,$40,$40
.byt $41,$40,$54,$70,$40
.byt $40,$60,$60,$4C,$40
.byt $40,$51,$40,$43,$40
.byt $40,$4A,$40,$4D,$40
.byt $40,$64,$40,$71,$40
.byt $43,$40,$43,$45,$40
.byt $4C,$40,$4C,$47,$40
.byt $70,$40,$71,$4E,$40
.byt $78,$43,$41,$73,$40
.byt $7E,$4C,$53,$61,$40
.byt $7F,$70,$5C,$71,$40
.byt $7F,$64,$78,$50,$40
.byt $4F,$67,$4C,$50,$40
.byt $43,$6E,$44,$40,$40
.byt $40,$73,$44,$40,$40
.byt $40,$41,$40,$40,$40
.byt $40,$41,$40,$40,$40

info_icon:
.byte $41,$7f,$7f,$7f,$60
.byte $43,$7f,$7f,$7f,$70
.byte $43,$7f,$7f,$7f,$70
.byte $43,$70,$40,$43,$70
.byte $43,$60,$40,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$40,$41,$70
.byte $43,$60,$40,$41,$70
.byte $43,$60,$4c,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$5e,$41,$70
.byte $43,$60,$4c,$41,$70
.byte $43,$70,$40,$43,$70
.byte $43,$7f,$7f,$7f,$70
.byte $43,$7f,$7f,$7f,$70
.byte $41,$7f,$7f,$7f,$60
.byte $40,$40,$7f,$40,$40
.byte $40,$43,$7f,$70,$40
.byte $40,$4f,$7f,$7c,$40


command_icon:
.byte $7f,$7f,$7f,$7f,$40
.byte $67,$7f,$7f,$7f,$40
.byte $7f,$7f,$7f,$7f,$40
.byte $60,$40,$40,$41,$40
.byte $68,$40,$40,$41,$40
.byte $6c,$40,$40,$41,$40
.byte $66,$40,$40,$41,$40
.byte $63,$40,$40,$41,$40
.byte $63,$40,$40,$41,$40
.byte $66,$40,$40,$41,$40
.byte $6c,$40,$40,$41,$40
.byte $68,$7e,$40,$41,$40
.byte $60,$40,$43,$41,$40
.byte $60,$40,$5b,$59,$40
.byte $60,$40,$5f,$79,$40
.byte $60,$40,$4c,$71,$40
.byte $60,$40,$78,$5d,$40
.byte $60,$40,$78,$5d,$40
.byte $60,$40,$4c,$71,$40
.byte $60,$40,$5f,$79,$40
.byte $60,$40,$5b,$59,$40
.byte $60,$40,$43,$41,$40
.byte $60,$40,$40,$41,$40
.byte $7f,$7f,$7f,$7f,$40





joy_icon:
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$7f,$40,$40
.byte $40,$4f,$7f,$7c,$40
.byte $40,$7f,$7f,$7e,$40
.byte $41,$7f,$7f,$7f,$60
.byte $43,$7f,$7f,$79,$70
.byte $47,$47,$7f,$79,$78
.byte $46,$53,$7f,$7f,$78
.byte $44,$51,$7f,$4f,$48
.byte $45,$7d,$7f,$4f,$48
.byte $44,$51,$7f,$7f,$78
.byte $46,$53,$7f,$79,$78
.byte $47,$47,$61,$79,$78
.byte $47,$7e,$40,$5f,$78
.byte $43,$7c,$40,$4f,$70
.byte $41,$78,$40,$47,$60
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40



chip_icon:
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$58,$40
.byte $40,$40,$41,$66,$40
.byte $40,$40,$46,$41,$60
.byte $40,$40,$58,$40,$58
.byte $40,$41,$60,$41,$68
.byte $40,$46,$40,$46,$48
.byte $40,$58,$40,$58,$68
.byte $41,$60,$41,$60,$78
.byte $46,$40,$46,$49,$70
.byte $47,$40,$58,$4e,$58
.byte $47,$71,$62,$5c,$48
.byte $47,$7e,$43,$66,$48
.byte $47,$7c,$67,$42,$40
.byte $41,$7c,$79,$62,$40
.byte $40,$5d,$70,$60,$40
.byte $40,$46,$58,$60,$40
.byte $40,$40,$48,$40,$40
.byte $40,$40,$48,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40


demo_icon:
.byte $7f,$7f,$7f,$7f,$40
.byte $67,$7f,$7f,$7f,$40
.byte $7f,$7f,$7f,$7f,$40
.byte $60,$40,$40,$41,$40
.byte $6e,$4e,$62,$59,$40
.byte $69,$48,$76,$65,$40
.byte $68,$68,$6a,$65,$40
.byte $68,$6e,$62,$65,$40
.byte $68,$68,$62,$65,$40
.byte $69,$48,$62,$65,$40
.byte $6e,$4e,$62,$59,$40
.byte $60,$40,$40,$41,$40
.byte $60,$40,$40,$41,$40
.byte $60,$58,$40,$41,$40
.byte $60,$5e,$40,$41,$40
.byte $60,$5f,$60,$41,$40
.byte $60,$5f,$78,$41,$40
.byte $60,$5f,$7e,$41,$40
.byte $60,$5f,$78,$41,$40
.byte $60,$5f,$60,$41,$40
.byte $60,$5e,$40,$41,$40
.byte $60,$58,$40,$41,$40
.byte $60,$40,$40,$41,$40
.byte $7f,$7f,$7f,$7f,$40


tools_icon:
.byte $40,$5c,$40,$41,$60
.byte $40,$4f,$40,$47,$70
.byte $40,$47,$60,$4f,$70
.byte $42,$43,$60,$4f,$60
.byte $43,$47,$60,$4f,$60
.byte $43,$6f,$60,$5f,$40
.byte $41,$7f,$60,$78,$40
.byte $41,$7f,$71,$70,$40
.byte $40,$7f,$7b,$60,$40
.byte $40,$41,$77,$40,$40
.byte $40,$40,$6e,$40,$40
.byte $40,$40,$5d,$40,$40
.byte $40,$40,$7b,$60,$40
.byte $40,$47,$77,$70,$40
.byte $40,$4f,$63,$78,$40
.byte $40,$5f,$61,$7c,$40
.byte $40,$7f,$60,$7e,$40
.byte $41,$7f,$40,$5f,$40
.byte $43,$7e,$40,$4f,$60
.byte $43,$7c,$40,$47,$60
.byte $43,$78,$40,$43,$40
.byte $41,$70,$40,$40,$40
.byte $40,$40,$40,$40,$40
.byte $40,$40,$40,$40,$40

exit_icon:
.byt $40,$40,$40,$78,$40
.byt $40,$40,$40,$67,$40
.byt $40,$40,$40,$60,$78
.byt $40,$40,$40,$60,$47
.byt $40,$40,$40,$64,$41
.byt $40,$40,$40,$66,$41
.byt $40,$40,$40,$47,$41
.byt $40,$7F,$7F,$7F,$61
.byt $40,$62,$7A,$63,$71
.byt $40,$6F,$57,$77,$79
.byt $40,$63,$6E,$77,$7D
.byt $40,$6F,$56,$77,$79
.byt $40,$62,$7A,$77,$71
.byt $40,$7F,$7F,$7F,$65
.byt $40,$40,$40,$47,$41
.byt $40,$40,$40,$66,$41
.byt $40,$40,$40,$64,$41
.byt $40,$40,$40,$60,$41
.byt $40,$40,$40,$60,$41
.byt $40,$40,$40,$60,$41
.byt $40,$40,$40,$7F,$41
.byt $40,$40,$40,$47,$7F
.byt $40,$40,$40,$40,$7F
.byt $40,$40,$40,$40,$47
.byt $40,$40,$40,$40,$40

clock_icon:
.byt $40,$40,$4F,$70,$40
.byt $40,$40,$70,$4C,$40
.byt $40,$43,$40,$43,$40
.byt $40,$44,$4D,$70,$60
.byt $40,$48,$78,$7C,$50
.byt $40,$51,$70,$5E,$58
.byt $40,$52,$7D,$7D,$48
.byt $40,$67,$5D,$7B,$64
.byt $40,$67,$7D,$7F,$64
.byt $41,$4F,$7D,$7F,$62
.byt $41,$4F,$7D,$7B,$72
.byt $41,$4F,$7D,$79,$72
.byt $41,$43,$7C,$40,$62
.byt $41,$4F,$7F,$79,$72
.byt $41,$4F,$7F,$7B,$62
.byt $40,$67,$7F,$7F,$64
.byt $40,$67,$5F,$7B,$64
.byt $40,$52,$7F,$7D,$48
.byt $40,$51,$7F,$7E,$48
.byt $40,$48,$7D,$7C,$50
.byt $40,$44,$45,$60,$60
.byt $40,$43,$40,$43,$40
.byt $40,$40,$70,$4C,$40
.byt $40,$40,$4F,$70,$40

network_icon:
.byt $40,$40,$40,$40,$40
.byt $40,$47,$78,$40,$40
.byt $40,$44,$48,$40,$40
.byt $40,$44,$48,$40,$40
.byt $40,$44,$48,$40,$40
.byt $40,$43,$70,$40,$40
.byt $40,$45,$58,$40,$40
.byt $40,$47,$78,$40,$40
.byt $40,$41,$60,$40,$40
.byt $40,$41,$60,$40,$40
.byt $40,$41,$60,$40,$40
.byt $40,$41,$60,$40,$40
.byt $43,$7F,$7F,$70,$40
.byt $47,$7F,$7F,$78,$40
.byt $46,$41,$60,$58,$40
.byt $46,$41,$60,$58,$40
.byt $46,$41,$60,$58,$40
.byt $46,$41,$60,$58,$40
.byt $5F,$67,$79,$7E,$40
.byt $50,$64,$49,$42,$40
.byt $50,$64,$49,$42,$40
.byt $50,$64,$49,$42,$40
.byt $4F,$43,$70,$7C,$40
.byt $55,$65,$59,$56,$40
.byt $5F,$67,$79,$7E,$40
