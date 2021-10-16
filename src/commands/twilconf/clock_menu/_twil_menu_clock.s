
.define CLOCK_POS_BAR $BB80+40*7+1
.define CLOCK_POS_DATE $BB80+40*7+2+7

.define CLOCK_COLOR_BAR $11


.define HOUR $00
.define MINUTES $03
.define SECONDS $06

.define DAY $9
.define MONTH $0C
.define YEAR $0F


.proc _twil_menu_clock
    ldx     #$09
    jsr     printToFirmDisplay

    lda     #$00
    sta     pos_bar_date

display_date:
@loop:

   BRK_TELEMON XRD0
   bcs      @no_char_action
   cmp      #10
   beq      @enter_key
   cmp      #13
   beq      @enter_key
   cmp      #8
   beq      @exit_menu
   cmp      #9
   beq      @exit_menu   

@no_char_action:


    ldx     #$00

    lda     DS1501_HOUR_REGISTER
    jsr     display
    lda     #':'
    sta     CLOCK_POS_DATE,x
    inx

    lda     DS1501_MINUTES_REGISTER
    jsr     display
    lda     #':'
    sta     CLOCK_POS_DATE,x
    inx

    lda     DS1501_SECONDS_REGISTER
    jsr     display
    lda     #' '
    sta     CLOCK_POS_DATE,x
    inx


    lda     DS1501_DATE_REGISTER
    jsr     display
    lda     #'/'
    sta     CLOCK_POS_DATE,x
    inx

    lda     DS1501_MONTH_REGISTER
    and     #%00011111
    jsr     display
    lda     #'/'
    sta     CLOCK_POS_DATE,x
    inx
    
    lda     DS1501_CENTURY_REGISTER
    jsr     display

    

    lda     DS1501_YEAR_REGISTER
    jsr     display

    



    jmp     @loop

@exit_menu:
    rts    
@enter_key:
    ldx     #$00
    lda     CLOCK_POS_DATE,x
    ora     #%10000000
    sta     CLOCK_POS_DATE,x
    lda     CLOCK_POS_DATE+1,x
    ora     #%10000000
    sta     CLOCK_POS_DATE+1,x    

    ldx     #$00
    stx     current_group
@read_again:
    BRK_TELEMON XRDW0            ; read keyboard
    ldx     current_group
    cmp     #27
    beq     @exit
    cmp     #$08
    beq     @left
    cmp     #$09
    beq     @right    
    cmp     #11
    beq     @up
    cmp     #13
    beq     @enter


    cmp     #10
    beq     @down
    jmp     @read_again    


    rts
@exit:
    jmp     display_date

@right:
    jmp     @right_management
@up:
    jmp     @up_management

@left:
    jmp     @left_management
    
@down:
    jmp     @down_management

@enter:
    ;dec     $BB80+40*7+2+7+1
    jsr     @enter_management
    jmp     @read_again     

@enter_management:
    ;ldx     current_group
    ;cpx     #HOUR
    ;bne     @not_minutes
    lda     CLOCK_POS_DATE-1,x
    lda     CLOCK_POS_DATE,x
    jsr     _ds1501_unlock_te
    jsr     @save_all
    jsr     _ds1501_lock_te
    rts
;@not_minutes:
    ;rts
    


@left_management:
    lda     pos_bar_date
    bne     @left_continue_minutes

   
    

    jmp     @read_again

@left_continue_minutes:
    dec     pos_bar_date
    cpx     #MINUTES
    bne     @left_continue_seconds
    
    jsr     @shutoff_group

    ldx     #HOUR
    stx     current_group
    
    jsr     @shuton_group

    jmp     @read_again    

@left_continue_seconds:
    cpx     #SECONDS
    bne     @left_continue_day
    
    jsr     @shutoff_group
    
    ldx     #MINUTES
    stx     current_group
    

    jsr     @shuton_group
    jmp     @read_again   
@left_continue_day:
    cpx     #DAY
    bne     @left_continue_month
    
    jsr     @shutoff_group
    
    ldx     #SECONDS
    stx     current_group
    

    jsr     @shuton_group

    jmp     @read_again    
@left_continue_month:
    cpx     #MONTH
    bne     @left_continue_year
    
    jsr     @shutoff_group
    
    ldx     #DAY
    stx     current_group
    
    jsr     @shuton_group

@exit_near_left:    
    jmp     @read_again    

@left_continue_year:
 
    jsr     @shutoff_group
    inx
    inx
    jsr     @shutoff_group
    
    ldx     #MONTH
    stx     current_group
    
    jsr     @shuton_group
    
    
    jmp     @read_again    
    



; RIGHT Management

@right_management:
    lda     pos_bar_date
    cmp     #$05
    beq     @exit_right
    inc     pos_bar_date
    cpx     #HOUR
    bne     @right_continue_minutes
    
    jsr     @shutoff_group
    
    ldx     #MINUTES
    stx     current_group
    
    jsr     @shuton_group

@exit_right:    
    jmp     @read_again

@right_continue_minutes:
    cpx     #MINUTES
    bne     @right_continue_seconds
    
    jsr     @shutoff_group

    ldx     #SECONDS
    stx     current_group
    
    jsr     @shuton_group

    jmp     @read_again    

@right_continue_seconds:
    cpx     #SECONDS
    bne     @right_continue_day
    
    jsr     @shutoff_group
    
    ldx     #DAY
    stx     current_group
    

    jsr     @shuton_group
    jmp     @read_again   
@right_continue_day:
    cpx     #DAY
    bne     @right_continue_month
    
    jsr     @shutoff_group
    
    ldx     #MONTH
    stx     current_group
    

    jsr     @shuton_group

    jmp     @read_again    
@right_continue_month:
    cpx     #MONTH
    bne     @right_continue_finish
    
    jsr     @shutoff_group
    
    ldx     #YEAR
    stx     current_group
    
    jsr     @shuton_group
    inx
    inx
    jsr     @shuton_group

@right_continue_finish:
    jmp     @read_again    

@up_management:
    cpx     #SECONDS
    beq     @up_seconds
    cpx     #MINUTES
    beq     @up_seconds ; Same than seconds (0 to 59)
    cpx     #DAY
    beq     @up_day
    cpx     #MONTH
    beq     @up_month    
    
    cpx     #YEAR
    beq     @up_year        

    jmp     @test_day

@up_year:
    inx
    inx
    lda     CLOCK_POS_DATE,x
    cmp     #'9'+$80
    bne     @not_midnight
    lda     CLOCK_POS_DATE+1,x
    cmp     #'9'+$80
    beq     @right_continue_finish
    


    jmp     @not_midnight

@up_month:


@not_00:
    lda     CLOCK_POS_DATE,x
    cmp     #'1'+$80
    bne     @not_midnight
    lda     CLOCK_POS_DATE+1,x
    cmp     #'2'+$80
    beq     @right_continue_finish
    jmp     @not_midnight

@up_day:
    lda     CLOCK_POS_DATE,x
    cmp     #'3'+$80
    bne     @not_midnight
    lda     CLOCK_POS_DATE+1,x
    cmp     #'1'+$80
    beq     @right_continue_finish
    jmp     @not_midnight

@up_seconds:
    
    lda     CLOCK_POS_DATE,x
    cmp     #'5'+$80
    bne     @not_midnight
    lda     CLOCK_POS_DATE+1,x
    cmp     #'9'+$80
    beq     @right_continue_finish
    jmp     @not_midnight

@test_day:
    lda     CLOCK_POS_DATE+1,x
    cmp     #'3'+$80
    bne     @not_midnight
    lda     CLOCK_POS_DATE,x
    cmp     #'2'+$80 ; 23 ?
    bne     @not_midnight
    jmp     @read_again
@not_midnight:    

    lda     CLOCK_POS_DATE+1,x
    cmp     #'9'+$80
    beq     @inc_digit_10
    inc     CLOCK_POS_DATE+1,x
    jmp     @read_again    
@inc_digit_10:
    lda     CLOCK_POS_DATE,x
    cmp     '3' ; 3 for hour ?
    bne     @next_digit
    jmp     @read_again
@next_digit:
    inc     CLOCK_POS_DATE,x
    lda     #'0'+$80
    sta     CLOCK_POS_DATE+1,x
    jmp     @read_again         


; Down
@down_management:
    cpx     #HOUR
    beq     @down_manage_down
    cpx     #MONTH
    beq     @down_month_up
    cpx     #YEAR
    beq     @down_year_up    
    jmp     @down_manage_down    

@down_year_up:
    inx
    inx    
    jmp     @down_manage_down

@down_month_up:
    lda     CLOCK_POS_DATE+1,x
    cmp     #'1'+$80
    bne     @down_manage_down
    lda     CLOCK_POS_DATE,x
    cmp     #'0'+$80
    bne     @down_manage_down
    jmp     @read_again


@down_manage_down:
    lda     CLOCK_POS_DATE+1,x   ; Is it 0 for the hour ?
    cmp     #'0'+$80
    bne     @not_midnight_down
    lda     CLOCK_POS_DATE,x
    cmp     #'0'+$80 
    bne     @not_midnight_down
    jmp     @read_again

@not_midnight_down:    
    lda     CLOCK_POS_DATE,x
    cmp     #'0'+$80
    beq     @dec_digit_10
    lda     CLOCK_POS_DATE+1,x
    cmp     #'0'+$80
    bne     @dec_digit_10
    dec     CLOCK_POS_DATE,x
    
    lda     #'9'+$80
    sta     CLOCK_POS_DATE+1,x

    jmp     @read_again     
    
    
    
    
    ;jmp     @read_again    
@dec_digit_10:
    dec     CLOCK_POS_DATE+1,x

    jmp     @read_again        


@shutoff_group:
    lda     CLOCK_POS_DATE,x
    and     #%01111111
    sta     CLOCK_POS_DATE,x

    lda     CLOCK_POS_DATE+1,x
    and     #%01111111
    sta     CLOCK_POS_DATE+1,x
    rts

@shuton_group:
    lda     CLOCK_POS_DATE,x
    ora     #%10000000
    sta     CLOCK_POS_DATE,x

    lda     CLOCK_POS_DATE+1,x
    ora     #%10000000
    sta     CLOCK_POS_DATE+1,x
    rts
@save_all:
    ldx     #HOUR
    jsr     @rol_and_compute
    sta     DS1501_HOUR_REGISTER
    
    ldx     #MINUTES
    jsr     @rol_and_compute
    sta     DS1501_MINUTES_REGISTER    
    
    ldx     #SECONDS
    jsr     @rol_and_compute
    sta     DS1501_SECONDS_REGISTER

    ldx     #DAY
    jsr     @rol_and_compute
    sta     DS1501_DATE_REGISTER

    ldx     #MONTH
    jsr     @rol_and_compute
   ; ora     DS1501_MONTH_REGISTER     
    sta     DS1501_MONTH_REGISTER
    
    ldx     #YEAR
    inx
    inx
    jsr     @rol_and_compute
   
    sta     DS1501_YEAR_REGISTER

    ; set century to 20
    lda     #%00100000
    sta     DS1501_CENTURY_REGISTER

    rts
@rol_and_compute:    
    lda     CLOCK_POS_DATE,x
    and     #%01111111
    sec
    sbc     #'0'
    asl
    asl
    asl
    asl
    sta     compute
    lda     CLOCK_POS_DATE+1,x
    and     #%01111111
    sec
    sbc     #'0'
    ora     compute
    rts
compute:
    .res 1    
current_group:
    .res    1
group:
    .res    1

display:  
    pha
    
    ror
    ror
    ror
    ror
    and     #%00001111
    tay
    lda     bcd_table,y
    sta     CLOCK_POS_DATE,x
    inx
    pla    
    and     #%00001111
    tay
    lda     bcd_table,y
    sta     CLOCK_POS_DATE,x
    inx
    rts
bcd_table:    
    .byte "0"
    .byte "1"
    .byte "2"
    .byte "3"
    .byte "4"
    .byte "5"
    .byte "6"
    .byte "7"
    .byte "8"
    .byte "9"

    .byte "A"
    .byte "B"
    .byte "C"
    .byte "D"
    .byte "E"
    .byte "F"
    .byte "G"
    .byte "H"
    .byte "I"
    .byte "J"

bcd_table_reverse:    
    .byte "0"
    .byte "1"
    .byte "2"
    .byte "3"
    .byte "4"
    .byte "5"
    .byte "6"
    .byte "7"
    .byte "8"
    .byte "9"    

pos_date:
    .byte HOUR
    .byte MINUTES
    .byte SECONDS
    .byte DAY
    .byte MONTH
    .byte YEAR
pos_bar_date:
    .res 1
.endproc    


.proc _ds1501_unlock_te
    ; Set write bit
    
    lda     DS1501_CTRLB_REGISTER
    and     #%01111111
    sta     DS1501_CTRLB_REGISTER
    rts
.endproc

.proc _ds1501_lock_te
    ; Set write bit
    
    lda     DS1501_CTRLB_REGISTER
    ora     #%10000000
    sta     DS1501_CTRLB_REGISTER
    rts
.endproc
