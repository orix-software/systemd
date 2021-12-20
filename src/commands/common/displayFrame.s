

;userzp := $80
;ptr2 := userzp+2

POS_LEFT_UP_CORNER:=($A000+(47*40))

POS_LEFT_DOWN_CORNER:=($A000+(194*40))

FRAME_NUMBER_LINE=2

TWIL_INTERFACE_FIRST_LINE_TEXT:=$BB80+40*7
TWIL_INTERFACE_LAST_LINE_TEXT:=$BB80+40*25
TWIL_INTERFACE_NUMBER_LINES_FOR_FRAME = $11

.define FRAME_HORIZONTAL_BAR_CHAR 94
.define FRAME_VERTICAL_BAR_CHAR   96

.proc _displayFrame
    lda     #<POS_LEFT_UP_CORNER
    sta     userzp
    lda     #>POS_LEFT_UP_CORNER
    sta     userzp+1
    
    lda     #<POS_LEFT_DOWN_CORNER
    sta     ptr2
    lda     #>POS_LEFT_DOWN_CORNER
    sta     ptr2+1

; horizontal bar
    ldx     #$00
@draw_next_line:    
    ldy     #$01    
@L11:
    lda     horizontal_bar,x
    sta     (userzp),y
    iny
    cpy     #39
    bne     @L11

    lda     userzp
    clc
    adc     #$28
    bcc     @no_inc2
    inc     userzp+1
@no_inc2:
    sta     userzp

    lda     ptr2
    clc
    adc     #$28
    bcc     @no_inc3
    inc     ptr2+1
@no_inc3:
    sta     ptr2


    inx
    cpx     #$06
    bne     @draw_next_line


    lda     #<POS_LEFT_UP_CORNER
    sta     userzp
    lda     #>POS_LEFT_UP_CORNER
    sta     userzp+1

    lda     #<POS_LEFT_DOWN_CORNER
    sta     ptr2
    lda     #>POS_LEFT_DOWN_CORNER
    sta     ptr2+1


    ldx     #$00
@L10:
    ldy     #$00    
    lda     up_left,x
    sta     (userzp),y
   
 

    ldy     #39
    lda     up_right,x
    sta     (userzp),y    



    lda     userzp
    clc
    adc     #$28
    bcc     @no_inc
    inc     userzp+1
@no_inc:
    sta     userzp


    lda     ptr2
    clc
    adc     #$28
    bcc     @no_inc5
    inc     ptr2+1
@no_inc5:
    sta     ptr2

    inx

    cpx     #$06
    bne     @L10


    ; Vertical

    lda     #<(POS_LEFT_UP_CORNER+6*40)
    sta     userzp
    lda     #>(POS_LEFT_UP_CORNER+6*40)
    sta     userzp+1

    ldx     #$00
 
@draw_vertical:
    ldy     #$00   
    lda     verticalBorder
    sta     (userzp),y
    ldy     #39
    sta     (userzp),y


    lda     userzp
    clc
    adc     #$28
    bcc     @no_inc4
    inc     userzp+1
@no_inc4:
    sta     userzp


    inx
    cpx     #FRAME_NUMBER_LINE
    bne     @draw_vertical


    lda     #<TWIL_INTERFACE_FIRST_LINE_TEXT
    sta     __pos+1
    sta     __pos2+1

    lda     #>TWIL_INTERFACE_FIRST_LINE_TEXT
    sta     __pos+2
    sta     __pos2+2

    ldy     #39
    lda     #FRAME_VERTICAL_BAR_CHAR
    ldx     #TWIL_INTERFACE_NUMBER_LINES_FOR_FRAME
L1:    
__pos:    
    sta     TWIL_INTERFACE_FIRST_LINE_TEXT
__pos2:    
    sta     TWIL_INTERFACE_FIRST_LINE_TEXT,y


    pha
    lda     __pos+1
    clc
    adc     #$28
    bcc     @S1
    inc     __pos+2
    inc     __pos2+2
@S1:
    sta     __pos+1
    sta     __pos2+1
    pla
    dex
    bpl     L1
; Display last line   

    lda     #'{'
    sta     TWIL_INTERFACE_LAST_LINE_TEXT
    
    lda     #'}'
    sta     TWIL_INTERFACE_LAST_LINE_TEXT+39

    ldx     #$00
@L200:    
    lda     horizontal_bar,x
    sta     46080+8*FRAME_HORIZONTAL_BAR_CHAR,x
    lda     down_left,x
    sta     46080+8*'{',x
    lda     down_right,x
    sta     46080+8*'}',x    
    inx
    cpx     #$08
    bne     @L200

    ldx     #$00
    lda     #FRAME_HORIZONTAL_BAR_CHAR ; ^
@L100:    
    sta     TWIL_INTERFACE_LAST_LINE_TEXT+1,x
    inx
    cpx     #38
    bne     @L100

    rts

down_left:
    .byt $71
    .byt $70
    .byt $58
    .byt $5C
    .byt $4F
    .byt $43
    .byt 64 ; Not used except for redef char
    .byt 64 ; Not used except for redef char    

up_left:
    .byte $43,$4f,$5c,$58,$70,$71

up_right:
    .byt $70
    .byt $7C
    .byt $4E
    .byt $46
    .byt $43
    .byt 99

horizontal_bar:
    .byt $7F
    .byt $7F
    .byt $40
    .byt $40
    .byt $7F
    .byt $7F
    .byt 64 ; Not used except for redef char
    .byt 64 ; Not used except for redef char

down_right:
    .byte $63,$43,$46,$4e,$7c,$78
    .byt 64 ; Not used except for redef char
    .byt 64 ; Not used except for redef char
.endproc


verticalBorder:
.byte  115
