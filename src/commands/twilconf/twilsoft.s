.export _start_twilsoft

.proc _start_twilsoft
    cli
    ldx     #$01 ; Loader banner
    jsr     twil_interface_init


    ldx     #$03
    jsr     _blitIcon

    ldx     #$04
    jsr     _blitIcon

    ldx     #$05
    jsr     _blitIcon
    jsr     listing
    cli
    rts
    jsr     twilfirm_menu_management_soft

@read_keyboard:
    BRK_TELEMON XRDW0            ; read keyboard
    asl     KBDCTC
    bcc     @checkkey
@exit:
    BRK_KERNEL XHIRES
    BRK_KERNEL XTEXT    
    rts

@checkkey:
    cmp     #27
    beq     @exit
    cmp     #$09
    beq     @go_right
    cmp     #$08
    beq     @go_left
    jmp     @read_keyboard
    
@go_right:
    ldx     twil_interface_current_menu
    cpx     #$02
    beq     @read_keyboard

    jsr     twil_interface_clear_menu
    
    lda     #$01
    jsr     twil_interface_change_menu
    
    inc     twil_interface_current_menu
    
    lda     #$00
    jsr     twil_interface_change_menu

    jsr     twilfirm_menu_management

    jmp     @read_keyboard
@go_left:
    ldx     twil_interface_current_menu
    beq     @read_keyboard
    
    jsr     twil_interface_clear_menu

    lda     #$01
    jsr     twil_interface_change_menu    
    
    dec     twil_interface_current_menu

    lda     #$00
    jsr     twil_interface_change_menu

    jsr     twilfirm_menu_management

    jmp     @read_keyboard

.endproc  

.proc   twilfirm_menu_management_soft
    
;    lda     twil_interface_current_menu
    ;beq     @display_menu_infos
    ;cmp     #$01
    ;beq     @display_menu_bank
    ;cmp     #$01
    ;beq     @display_menu_upgrade
    ;rts
;@display_menu_bank:
    ;jsr     twil_menu_bank
    ;rts

;@display_menu_upgrade:
    ;jsr     twil_menu_upgrade
    ;rts

;@display_menu_infos:    
    ;jsr     twil_menu_infos

;    rts
    rts
.endproc

.include "../softgui/listing.s"

;string_low:
    ;.byte   <str_twilighte_firmware_version
    ;.byte   <str_default_storage
    ;.byte   <str_cpu
    ;.byte   <str_microdisc_register
;string_high:
 ;   .byte   >str_twilighte_firmware_version    
    ;.byte   >str_default_storage    
    ;.byte   >str_cpu
    ;.byte   >str_microdisc_register    

;pos_string_low:
    ;.byte   <($BB80+40*7+2)
    ;.byte   <($BB80+40*8+2)
    ;.byte   <($BB80+40*9+2)
    ;.byte   <($BB80+40*10+2)

;pos_string_high:
    ;.byte   >($BB80+40*7+2)
    ;.byte   >($BB80+40*8+2)
    ;.byte   >($BB80+40*9+2)
    ;.byte   >($BB80+40*10+2)





;.include "twil_interface_vars.s"
;.include "twil_interface_init.s"
;.include "twil_interface_change_menu.s"
;.include "twil_interface_clear_menu.s"

;.include "displayTwilighteBanner.s"
;.include "displayFrame.s"
;.include "blitIcon.s"



