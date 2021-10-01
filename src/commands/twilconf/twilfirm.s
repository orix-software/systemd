.define TWIL_INC_LOADED  twil_inc_loaded

.define TWIL_MASK_REGISTER_VERSION 7

.export _start_twilfirmware


.define TWIL_ACTION_MEMORY_MENU   $01
.define TWIL_ACTION_UPGRADE_MENU  $02
.define TWIL_ACTION_EXIT_FIRM2    $03


.define TWIL_ACTION_EXIT_FIRM3    $02

.define TWIL_ACTION_CLOCK         $04 ; Firm 3
.define TWIL_ACTION_NETWORK       $05 ; Firm 3

.define TWIL_MAX_FIRMWARE_MENU_ICON 1

.define TWILFIRM_MAX_MENU_ENTRY_FIRM_3 6
.define TWILFIRM_MAX_MENU_ENTRY_FIRM_2 4


pos_current_letter_charset:=userzp
pos_text_hires:=userzp+2

twilfirm_ptr2:= userzp+4

twil_get_bank_empty_ptr1:=twilfirm_ptr2

.proc _start_twilfirmware
    cli
    ldx     #$00
    jsr     twil_interface_init

    jsr     twil_interface_clear_menu 


    lda     $342 ; Get version
    and     #TWIL_MASK_REGISTER_VERSION
    cmp     #$03
    beq     @version3


    ldx     #$00
    jsr     _blitIcon

    ldx     #$01
    jsr     _blitIcon

    ldx     #$02
    jsr     _blitIcon

    
    ldx     #$07
    jsr     _blitIcon
    jmp     @run_menu
@version3:
    ldx     #$00
    jsr     _blitIcon
    
    ldx     #$08
    jsr     _blitIcon

    ldx     #$09
    jsr     _blitIcon

    ldx     #$0A
    jsr     _blitIcon


@run_menu:
    jsr     twilfirm_menu_management

@read_keyboard:

    BRK_TELEMON XRDW0            ; read keyboard

    asl     KBDCTC
    bcc     @checkkey
@exit:    
    ; restore chars 
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE

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
    cpx     #TWIL_MAX_FIRMWARE_MENU_ICON
    beq     @read_keyboard

    jsr     twil_interface_clear_menu
    
    lda     #$01
    jsr     twil_interface_change_menu
    
    inc     twil_interface_current_menu
    
    lda     #$00
    jsr     twil_interface_change_menu

    jsr     twilfirm_menu_management ; it return 1 if there is an action to exit
    cmp     #$01
    beq     @exit
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

.proc   twilfirm_menu_management
    

    lda     $342 ; Get version
    and     #%00000011
    cmp     #$03
    beq     @version3

    lda     twil_interface_current_menu         ; Get current menu 
    beq     @display_menu_infos
    cmp     #TWIL_ACTION_MEMORY_MENU
    beq     @memory_menu
    cmp     #TWIL_ACTION_UPGRADE_MENU
    beq     @upgrade_menu
    cmp     #TWIL_ACTION_EXIT_FIRM2
    beq     @exit_interface

    rts
@memory_menu:    
    jmp     _twil_displays_banks    
    rts
@upgrade_menu:
    rts    
@version3:    
    lda     twil_interface_current_menu         ; Get current menu 
    beq     @display_menu_infos
    cmp     #TWIL_ACTION_CLOCK
    beq     @clock_interface
    cmp     #TWIL_ACTION_NETWORK
    beq     @network_interface    
    cmp     #TWIL_ACTION_EXIT_FIRM3
    beq     @exit_interface
    rts
@network_interface:
    lda     #$00
    rts
@clock_interface:
    lda     #$00
    rts    
@exit_interface:
    ldx     #$05
    jsr     printToFirmDisplay
    BRK_TELEMON XRDW0 
    cmp     #13
    beq     @exit_interface_confirmed
    lda     #$00
    rts
@exit_interface_confirmed:    
    lda     #$01
    rts

@display_menu_bank:
    jsr     twil_menu_bank
    lda     #$00
    rts

@display_menu_upgrade:
    jsr     twil_menu_upgrade
    lda     #$00
    rts

@display_menu_infos:    
    jsr     twil_menu_infos

    rts
.endproc

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
    ; Return pos and Y
    lda     @__modify+1
    ldx     @__modify+2

    rts
.endproc

.proc   twil_menu_bank

    jsr     read_banks
    ;lda     #$11
    ;sta    $bb80
    rts
.endproc

.proc   twil_menu_upgrade

    rts
.endproc


tmp1_bank:
    .res 1

str_6502:
    .asciiz "6502"
str_65C02:
    .asciiz "65C02"    
str_65C816:
    .asciiz "65C816"    
str_sdcard:
    .asciiz "SDCARD"    
str_usb:
    .asciiz "USB"    

.include "infos_menu/twil_menu_infos.s"
.include "memory_menu/_twil_displays_banks.s"
.include "twil_interface_vars.s"
.include "twil_interface_init.s"
.include "twil_interface_change_menu.s"
.include "twil_interface_clear_menu.s"

.include "displayTwilighteBanner.s"
.include "displayFrame.s"
.include "blitIcon.s"


str_would_you_like_to_exit:
    .asciiz "Press enter to return to shell"

str_twilighte_firmware_version:
    .asciiz "Firmware version   : "    
str_default_storage:
    .asciiz "Default storage    : "
str_cpu:
    .asciiz "CPU                : "
str_microdisc_register:
    .asciiz "Microdisc register : YES"
str_twilighte_rtc:
    .asciiz "Real Time Clock    : YES"    
str_twilighte_battery:
    .asciiz "On board battery   : YES"    
str_twilighte_battery_level:
    .asciiz "Battery level      : "        
str_ip_addr:
    .asciiz "IP : "


string_low:
    .byte   <str_twilighte_firmware_version ; 0 
    .byte   <str_default_storage            ; 1
    .byte   <str_cpu                        ; 2
    .byte   <str_microdisc_register         ; 3
    .byte   <str_twilighte_rtc              ; 4
    .byte   <str_would_you_like_to_exit     ; 5
    .byte   <str_ip_addr                    ; 6
    .byte   <str_twilighte_battery          ; 7
    .byte   <str_twilighte_battery_level    ; 8

        

string_high:
    .byte   >str_twilighte_firmware_version    
    .byte   >str_default_storage    
    .byte   >str_cpu
    .byte   >str_microdisc_register    
    .byte   >str_twilighte_rtc    
    .byte   >str_would_you_like_to_exit
    .byte   >str_ip_addr
    .byte   >str_twilighte_battery
    .byte   >str_twilighte_battery_level    

pos_string_low:
    .byte   <($BB80+40*7+2)  ; FIRMWARE
    .byte   <($BB80+40*9+2)  ; Default storage
    .byte   <($BB80+40*8+2)  ; CPU
    .byte   <($BB80+40*10+2) ; Microdisc register
    .byte   <($BB80+40*11+2) ; RTC
    .byte   <($BB80+40*7+2)  ; Exit
    .byte   <($BB80+40*7+2)  ; IP
    .byte   <($BB80+40*12+2) ; on board battery
    .byte   <($BB80+40*13+2) ; Battery level

pos_string_high:
    .byte   >($BB80+40*7+2)
    .byte   >($BB80+40*9+2)
    .byte   >($BB80+40*8+2)
    .byte   >($BB80+40*10+2)
    .byte   >($BB80+40*11+2) ; RTC
    .byte   >($BB80+40*7+2)  ; Exit
    .byte   >($BB80+40*7+2)  ; Firmware
    .byte   >($BB80+40*12+2) ; on board battery
    .byte   >($BB80+40*13+2) ; Battery level

.proc _getcpu
    lda     #$00
    .byt    $1A             ; .byte $1A ; nop on nmos, "inc A" every cmos
    cmp     #$01
    bne     @is6502Nmos
.p816    
    ; is it 65c816
    xba                     ; .byte $EB, put $01 in B accu (nop on 65C02/65SC02)
    dec     a               ; .byte $3A, A=$00
    xba                     ; .byte $EB, A=$01 if 65816/65802 and A=$00 if 65C02/65SC02
    inc     a               ; .byte $1A, A=$02 if 65816/65802 and A=$01 if 65C02/65SC02
    cmp     #$02
    beq     @isA65C816
    lda     #CPU_65C02       ; it's a 65C02
    rts
@isA65C816:
    lda     #CPU_65816
    rts
@is6502Nmos:
    lda     #CPU_6502
    rts
.endproc

