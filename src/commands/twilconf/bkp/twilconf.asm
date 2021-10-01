;.include "telestrat.inc"

;.export _start_twilfirmware

pos_current_letter_charset:=userzp
pos_text_hires:=userzp+2

.proc _twilconf
   ; BRK_TELEMON XHIRES
    ; redef

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
   ; sta     $A000+40*55




    jsr     _displayTwilighteBanner
    jsr     _displayFrame

    
    ldx     #$00
    jsr     _blitIcon

    ldx     #$04
    jsr     _blitIcon

    ldx     #$00            ; Firmware version
    jsr     printToFirmDisplay
    
    ldx     #$01            ; Default storage
    jsr     printToFirmDisplay

    lda     $342
    and     #%00000111
    clc
    adc     #48
    sta     $BB80+40*7+2+19

    rts



        ;cputsxy(1,8,"Firmware version : 2");
        ;cputsxy(1,9,"CPU : 6502");
        ;cputsxy(1,10,"Microdisc register : yes");
        ;cputsxy(1,11,"Default storage : Usb");    
.endproc  


string_low:
    .byte   <str_twilighte_firmware_version
    .byte   <str_default_storage
string_high:
    .byte   >str_twilighte_firmware_version    
    .byte   >str_default_storage    
pos_string_low:
    .byte   <($BB80+40*7+2)
    .byte   <($BB80+40*8+2)

pos_string_high:
    .byte   >($BB80+40*7+2)
    .byte   >($BB80+40*8+2)



str_twilighte_firmware_version:
    .asciiz   "Firmware version : "    
str_default_storage:
    .asciiz "Default storage : Usb"



.proc printToFirmDisplay

    lda     string_low,x
    sta     pos_current_letter_charset
    lda     string_high,x
    sta     pos_current_letter_charset+1

    lda     pos_string_low,x
    sta     @__modify+1
    lda     pos_string_high,x
    sta     @__modify+2

    ldy     #$00
@L1:    
    lda     (pos_current_letter_charset),y
    beq     @out
@__modify:    
    sta     $BB80+40*7+2,y
    iny
    bne     @L1
@out:
    rts
.endproc


tmp1_bank:
    .res 1
saveX:
    .res 1

save_posx_string:
    .res 1
save_posy_string:
    .res 1    
save_string:
    .res 1


.include "displayTwilighteBanner.s"
.include "displayFrame.s"
.include "blitIcon.s"
