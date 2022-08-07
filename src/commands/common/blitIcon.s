




ptr_pos_img_src := userzp ; 2
ptr_pos_img_dest := userzp+2 ; 2

.define ICON_SIZE_X $04

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
    cpy     #ICON_SIZE_X
    bne     @L1

    lda     ptr_pos_img_src
    clc 
    adc     #ICON_SIZE_X
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
    .byte <($a000+POSY_ICON*40+13) ; Game
    .byte <($a000+POSY_ICON*40+7)
    .byte <($a000+POSY_ICON*40+19) ; Tools
    .byte <($a000+POSY_ICON*40+20)
    .byte <($a000+POSY_ICON*40+13)  ; Exit firm 2
    .byte <($a000+POSY_ICON*40+7)  ; Network firm v3
    .byte <($a000+POSY_ICON*40+19) ; Exit firm v3
    .byte <($a000+POSY_ICON*40+13) ; clock (firm3)
    .byte <($a000+POSY_ICON*40+1)  ; Rom for loader
    .byte <($a000+POSY_ICON*40+34) ; exit loader
    .byte <($a000+POSY_ICON*40+13) ; Engrenage to fix
    .byte <($a000+POSY_ICON*40+25) ; Music

icons_list_pos_high:
    .byte >($a000+POSY_ICON*40+1)  ; 0 Infos
    .byte >($a000+POSY_ICON*40+7)  ; 1
    .byte >($a000+POSY_ICON*40+13) ; 2
    .byte >($a000+POSY_ICON*40+13) ; 3 Game
    .byte >($a000+POSY_ICON*40+7)  ; 4 demo
    .byte >($a000+POSY_ICON*40+19) ; 5 Tools
    .byte >($a000+POSY_ICON*40+20) ; 6
    .byte >($a000+POSY_ICON*40+19)  ; 7 Exit firm 2
    .byte >($a000+POSY_ICON*40+7)  ; 8 Network
    .byte >($a000+POSY_ICON*40+19) ; 9 Exit firm v3
    .byte >($a000+POSY_ICON*40+13) ; $0A   ; clock (firm3)
    .byte >($a000+POSY_ICON*40+1)  ; $0B Rom for launcher
    .byte >($a000+POSY_ICON*40+34) ; $0C Exit loader
    .byte >($a000+POSY_ICON*40+13) ; $0D Engrenage to fix
    .byte >($a000+POSY_ICON*40+25) ; Music

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
    .byte <engrenage_icon   ; $0D
    .byte <music_icon       ; $0E
    
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
    .byte >engrenage_icon 
    .byte >music_icon

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
    .byt $40,$40,$40,$40,$40
    .byt $40,$40,$40,$40,$40

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

.include "icons/info_icon.s"
.include "icons/joy_icon.s"
chip_icon:
.include "icons/rom_icon.s"
.include "icons/demo_icon.s"
tools_icon:
.include "icons/tool_icon.s"
.include "icons/exit_icon.s"
.include "icons/clock_icon.s"
.include "icons/network_icon.s"
.include "icons/music_icon.s"
.include "icons/engrenage_icon.s"
