.proc _start_twilmenubank
    cli
    ldx     #$00
    jsr     twil_interface_init

    jsr     twil_interface_clear_menu 

    ldx     #TWIL_INFO_ICON_ID
    jsr     _blitIcon

    ldx     #TWIL_ACTION_MEMORY_MENU
    jsr     _blitIcon

    ldx     #TWIL_ACTION_UPGRADE_MENU
    jsr     _blitIcon

    rts
.endproc
