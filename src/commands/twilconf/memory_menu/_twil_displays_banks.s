    TRUE = 0
    FALSE = 1
 
    save_bank                       := userzp+1	; 1 byte
    save_twilighte_register         := userzp+2 ; 1 bytes
    save_twilighte_banking_register := userzp+3 ; 1 bytes
    bank_decimal_current_bank       := userzp+4 ; 1 byte
    ptr_routine_bank                := userzp+5 ; 2 bytes
    current_bank_tmp                := userzp+7
    ptr_display                     := userzp+9
    ptr_signature                   := userzp+11
    is_a_valid_rom                  := userzp+13
    switch_to_rom                   := userzp+14

.proc _twil_displays_banks


    lda      VIA2::PRA
    sta      save_bank

    lda      #<($bb80+7*40+2)
    sta      ptr_display
  
    lda      #>($bb80+7*40+2)
    sta      ptr_display+1

    malloc   512,ptr_routine_bank,str_oom

    lda     ptr_routine_bank
    sta     __read_rom_info+1
    sta     __copy+1
    sta     __copy2+1
    
    lda     ptr_routine_bank+1
    sta     __read_rom_info+2
    sta     __copy+2
    sta     __copy2+2
    inc     __copy2+2

    ldy      #$00
loop:    
    lda      routine_display_signature_into_ram,y
__copy:    
    sta      $dead,y
    lda      routine_display_signature_into_ram+256,y
__copy2:    
    sta      $dead,y    
    iny
    bne      loop

	
    lda     #64
    sta     bank_decimal_current_bank


    lda     TWILIGHTE_BANKING_REGISTER
    sta     save_twilighte_banking_register

    ; switch to ram
    lda     TWILIGHTE_REGISTER
    sta     save_twilighte_register

    
    lda     #FALSE
    sta     is_a_valid_rom
restart:
    lda     bank_decimal_current_bank
    cmp     #52 ; Bank 0 Skip
    bne     __read_rom_info
    dec     bank_decimal_current_bank
    lda     bank_decimal_current_bank
__read_rom_info:
    jsr     $dead 
    lda     bank_decimal_current_bank   
    cmp     #$01
    beq     @finished
    dec     bank_decimal_current_bank
    
    lda     is_a_valid_rom
    cmp     #FALSE
    beq     restart

    lda     ptr_display
    clc
    adc     #$28
    bcc     @no_inc
    inc     ptr_display+1   
@no_inc:
    sta     ptr_display  
    
    lda     #FALSE
    sta     is_a_valid_rom

    jmp     restart
       
@finished:  

   ; mfree (ptr_routine_bank)
    lda     #$00

    rts
.endproc

.proc routine_display_signature_into_ram

    sei

    jsr     _twil_get_registers_from_id_bank

    stx     TWILIGHTE_BANKING_REGISTER
    sta     current_bank_tmp

    lda     VIA2::PRA
    and     #%11111000
    ora     current_bank_tmp
    sta     VIA2::PRA

    lda     bank_decimal_current_bank
    cmp     #32   ; Does signature is in rom ?
    bcc     @rom
    bne     @display_signature
@rom:
    lda     TWILIGHTE_REGISTER
 
    and     #%11011111
    sta     TWILIGHTE_REGISTER

    lda     $FFF8
    bne     @display_signature
    lda     $FFF9
    bne     @display_signature
    beq     @no_signature

@display_signature:



    lda     $FFF0 ; empty rom ?
    beq     @out
    ; check if orix ROM ? 
    lda     $FFFE
    cmp     #$FA
    bne     @out

    
    lda     $FFF8
    sta     ptr_signature
    lda     $FFF9
    sta     ptr_signature+1
    cmp     #$C0   ; Does signature is in rom ?
    bcc     @out

    lda     #TRUE
    sta     is_a_valid_rom

    ldy     #$00
@loop:
   
    lda     (ptr_signature),y
    beq     @out
    cmp     #' '                        ; 'a'
    bcc     @none_char
    cmp     #$7F                        ; '7f'
    bcs     @none_char

    sta     (ptr_display),y
@none_char:    
    iny
    cpy     #30
    bne     @loop

@no_signature:    
@out:    

    lda     save_bank
    sta     VIA2::PRA

    lda     save_twilighte_register
    sta     TWILIGHTE_REGISTER

    lda     save_twilighte_banking_register
    sta     TWILIGHTE_BANKING_REGISTER
    cli
    rts

.endproc
