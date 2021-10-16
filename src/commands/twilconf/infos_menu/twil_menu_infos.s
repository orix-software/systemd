
CH376_GET_IC_VER      = $01

.proc   twil_menu_infos
    ldx     #$00            ; Firmware version
    jsr     printToFirmDisplay
    sta     @__put_version+1
    stx     @__put_version+2

    ldx     #$0C               ; Firmware version
    jsr     printToFirmDisplay

    jsr     _ch376_ic_get_ver
    clc     
    adc     #$30
    sta     $bb80+40*10+25

    ; And GET VERSION
    lda     TWILIGHTE_REGISTER ; Get version
    and     #TWIL_MASK_REGISTER_VERSION
    clc     
    adc     #$30
    sta     $bb80+120
@__put_version:
    sta     $dead,y

    lda     TWILIGHTE_REGISTER ; Get version
    and     #TWIL_MASK_REGISTER_VERSION

    cmp     #$01
    beq     @firm1
    cmp     #$02
    beq     @firm2
    ; Firm 3



    ldx     #$04            ; 
    jsr     printToFirmDisplay

    ldx     #$07            ;  on board battery
    jsr     printToFirmDisplay

    ldx     #$08            ; Battery level 
    jsr     printToFirmDisplay
    ; Check battery level

    lda     DS1501_CTRLA_REGISTER
    and     #%10000000
    cmp     #%10000000
    bne     @full

    ldx     #$0A            ; Low
    jsr     printToFirmDisplay
    jmp     @full

@full:
    ldx     #$0B            ; Full
    jsr     printToFirmDisplay


@firm2:
    ldx     #$03            ; Microdisc register
    jsr     printToFirmDisplay

@firm1:
    ldx     #$02            ; Cpu
    jsr     printToFirmDisplay
    sta     @__put_cpu+1
    stx     @__put_cpu+2
    sty     tmp1_bank

    jsr     _getcpu    
    cmp     #CPU_65816
    bne     @check_6502
    
    lda     #<str_65C816
    sta     @__L100+1
    lda     #>str_65C816
    sta     @__L100+2
    jmp     @display_cpu_type

@check_6502:    
    cmp     #CPU_6502
    bne     @check_65C02
    lda     #<str_6502
    sta     @__L100+1
    lda     #>str_6502
    sta     @__L100+2
    jmp     @display_cpu_type
@check_65C02:
    lda     #<str_65C02
    sta     @__L100+1
    lda     #>str_65C02
    sta     @__L100+2


@display_cpu_type:
    ldy     tmp1_bank
    ldx     #$00
@__L100:    
    lda     $dead,x
    beq     @out_cpu
@__put_cpu:
    sta     $dead,y
    inx
    iny
    bne     @__L100
@out_cpu:    

    ldx     #$01            ; Default storage
    jsr     printToFirmDisplay
    sta     @__put_device+1
    stx     @__put_device+2
    sty     tmp1_bank

    ldx     #$02    ; XVARS_KERNEL_CH376_MOUNT
    BRK_KERNEL XVARS
    
    sta     @__get_default_device+1
    sty     @__get_default_device+2
@__get_default_device:
    lda     $dead
    cmp     #$06 ; CH376_SET_USB_MODE_CODE_USB_HOST_SOF_PACKAGE_AUTOMATICALLY
    beq     @usb
    
    lda     #<str_sdcard
    sta     @__L102+1
    lda     #>str_sdcard
    sta     @__L102+2
    jmp     @display_default_device
@usb:
    lda     #<str_usb
    sta     @__L102+1
    lda     #>str_usb
    sta     @__L102+2

@display_default_device:
    ldy     tmp1_bank
    ldx     #$00
@__L102:    
    lda     $dead,x
    beq     @out_default_device
@__put_device:
    sta     $dead,y
    inx
    iny
    bne     @__L102
@out_default_device:


    rts    
.endproc

.proc _ch376_ic_get_ver
    lda     #CH376_GET_IC_VER
    sta     CH376_COMMAND
    lda     CH376_DATA
    and     #%00111111 ; A contains revision

    rts
.endproc    