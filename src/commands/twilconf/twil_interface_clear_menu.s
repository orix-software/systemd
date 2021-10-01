.define TWIL_NUMBER_OF_CHAR_TO_CLEAR_IN_A_LINE 39

.proc twil_interface_clear_menu

    lda     #<TWIL_INTERFACE_FIRST_LINE_TEXT
    sta     __pos+1
    lda     #>TWIL_INTERFACE_FIRST_LINE_TEXT
    sta     __pos+2

    ldy     #$01
    ldx     #17
    

L1: 
    lda     #32   

    ldy     #$01  
__pos:    
    sta     $A000,y
    iny
    cpy     #TWIL_NUMBER_OF_CHAR_TO_CLEAR_IN_A_LINE
    bne     __pos


    lda     __pos+1
    clc
    adc     #$28
    bcc     @S1
    inc     __pos+2
@S1:
    sta     __pos+1

    dex
    bpl     L1
    rts
value_on:
    .res    1
value_off:
    .res    1    


.endproc

