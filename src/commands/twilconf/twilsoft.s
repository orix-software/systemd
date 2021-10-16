.export _start_twilsoft
 

.proc _start_twilsoft
    cli
    ldx     #$01 ; Loader banner
    jsr     twil_interface_init

    ldx     #$0B
    jsr     _blitIcon

    ldx     #$0C
    jsr     _blitIcon
@start_menu_bank:
    jsr     _start_twilmenubank
    cmp     #$09
    beq     @exit_menu
    rts
@exit_menu:    
    lda     #$01
    jsr     twil_interface_change_menu
    inc     twil_interface_current_menu
    
    jsr     twil_interface_clear_menu

    lda     #$00
    jsr     twil_interface_change_menu  
@exit_interface:
    ldx     #$05
    jsr     printToFirmDisplay
@read_key_exit:    
    BRK_TELEMON XRDW0 
    cmp     #13
    beq     @exit_interface_confirmed
    cmp     #08
    beq     @display_twil_menu_bank  
    jmp     @read_key_exit

@exit_interface_confirmed: 
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE
    rts

@display_twil_menu_bank:
    lda     #$01
    jsr     twil_interface_change_menu
    dec     twil_interface_current_menu
    
    jsr     twil_interface_clear_menu

    lda     #$00
    jsr     twil_interface_change_menu 

    jmp     @start_menu_bank 
.endproc
