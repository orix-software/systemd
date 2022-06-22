.include "../dependencies/ds1501-lib/src/include/ds1501.s"

; 24 secs de retard le 11/01
.define TWIL_ICON_GAME               $03
.define TWIL_ICON_DEMO               $04
.define TWIL_ICON_TOOLS              $05
.define TWIL_ICON_MUSIC              $06

.define TWIL_ICON_CLOCK_ID           $0A
.define TWIL_ICON_ROM_ID             $0B
.define TWIL_ICON_EXIT_LOADER        $0C
.define TWIL_ICON_ENGRENAGE_FIRMWARE $0D
.define TWIL_ICON_MUSIC_LOADER       $0E

.define TWIL_ON_ICON                 $00
.define TWIL_OFF_ICON                $01

.define TWIL_INC_LOADED  twil_inc_loaded

.define TWIL_MASK_REGISTER_VERSION 7

.export _start_twilfirmware

.define TWIL_INFO_ICON_ID         0
.define TWIL_INFO_MEMORY_ID       $01


.define TWIL_SWITCH_OFF_ICON      $00
.define TWIL_SWITCH_ON_ICON       $01

.define TWIL_ACTION_MEMORY_MENU   $01
.define TWIL_ACTION_UPGRADE_MENU  $02
.define TWIL_ACTION_EXIT_FIRM2    $02
.define TWIL_ACTION_CLOCK         $02 ; Firm 3

.define TWIL_GEAR_ICON_ID         $0D



.include "../common/keyboard.inc"
.define TWIL_FIRMWARE_WITH_ETHERNET $03


.define TWIL_ACTION_EXIT_FIRM3    $05


.define TWIL_ACTION_NETWORK       $05 ; Firm 3

.define TWIL_MAX_FIRMWARE_MENU_ICON 1

.define TWILFIRM_MAX_MENU_ENTRY_FIRM_3 4
.define TWILFIRM_MAX_MENU_ENTRY_FIRM_2 3 ; 0 to 3


; Don't use userzp+4 !!! It's a malloc for return routine in twilbank of shell command (when funct + T and funct +L are pressed)

pos_current_letter_charset:=userzp
pos_text_hires:=userzp+2

twilfirm_ptr2:= userzp+6

twil_get_bank_empty_ptr1:=twilfirm_ptr2

.proc _start_twilfirmware
    cli
    ldx     #$00
    jsr     twil_interface_init

    jsr     twil_interface_clear_menu 

    ldx     #TWIL_INFO_ICON_ID
    jsr     _blitIcon

    ldx     #TWIL_ACTION_MEMORY_MENU
    jsr     _blitIcon

    ldx     #TWIL_GEAR_ICON_ID
    ;jsr     _blitIcon

    ;ldx     #TWIL_ACTION_UPGRADE_MENU
    ;jsr     _blitIcon


    lda     $342 ; Get version
    and     #TWIL_MASK_REGISTER_VERSION
    cmp     #TWIL_FIRMWARE_WITH_ETHERNET
    beq     @version4
    ; Firm 2
    lda     #TWILFIRM_MAX_MENU_ENTRY_FIRM_2
    sta     twil_max_menu_icon_firmware
    
    ldx     #$07
    jsr     _blitIcon
    jmp     @run_menu
@version4:
    lda     #TWILFIRM_MAX_MENU_ENTRY_FIRM_3
    sta     twil_max_menu_icon_firmware

    ldx     #$09
    jsr     _blitIcon

    ldx     #TWIL_ICON_CLOCK_ID
    jsr     _blitIcon


@run_menu:
    jsr     twilfirm_menu_management

read_keyboard:

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
    beq     go_left_twilfirm
    jmp     read_keyboard
    
@go_right:
    ldx     twil_interface_current_menu
    cpx     twil_max_menu_icon_firmware
    beq     read_keyboard

    jsr     twil_interface_clear_menu
    
    lda     #TWIL_SWITCH_ON_ICON
    jsr     twil_interface_change_menu
    
    inc     twil_interface_current_menu

    jsr     twilfirm_menu_management ; it return 1 if there is an action to exit
    cmp     #$01
    beq     @exit
    jmp     read_keyboard


go_left_twilfirm:
    ldx     twil_interface_current_menu
    beq     @exit_go_left_twilfirm

    jsr     twil_interface_clear_menu

    dec     twil_interface_current_menu

    jsr     twilfirm_menu_management
    cmp     #$01
    bne     @exit_go_left_twilfirm
        ; restore chars


    rts
@exit_go_left_twilfirm:

    lda     #TWIL_ON_ICON
    jsr     twil_interface_change_menu

    jmp     read_keyboard
.endproc


.proc   twilfirm_menu_management


    lda     $342 ; Get version
    and     #%00000011
    cmp     #TWIL_FIRMWARE_WITH_ETHERNET
    beq     @version4

    lda     twil_interface_current_menu         ; Get current menu 
    beq     @display_menu_infos
    cmp     #TWIL_ACTION_MEMORY_MENU
    beq     @memory_menu
    ;cmp     #TWIL_ACTION_UPGRADE_MENU
    ;beq     @upgrade_menu
    cmp     #TWIL_ACTION_EXIT_FIRM2
    beq     @exit_interface
    rts


@memory_menu:
    jmp     _twil_displays_banks

@upgrade_menu:
    rts
@version4:
    lda     twil_interface_current_menu         ; Get current menu 
    beq     @display_menu_infos
    cmp     #TWIL_ACTION_MEMORY_MENU
    beq     @memory_menu
    ;cmp     #TWIL_ACTION_UPGRADE_MENU
    ;beq     @upgrade_menu
    cmp     #TWIL_ACTION_CLOCK
    beq     @clock_interface
    ;cmp     #TWIL_ACTION_NETWORK
    ;beq     @network_interface    
    cmp     #TWIL_ACTION_EXIT_FIRM3
    beq     @exit_interface
    rts
@network_interface:
    lda     #$01
    rts
@clock_interface:
    jsr     _twil_menu_clock
    ; Clock menu get keyboard, then this is missing here then manage here case left or right
    cmp     #$08
    beq     @exit_interface_from_clock
    cmp     #$09
    beq     @display_menu_upgrade_from_clock
    lda     #$00
    rts
@exit_interface_from_clock:
    jsr     twil_interface_change_menu
    inc     twil_interface_current_menu         
    jsr     twil_interface_change_menu
@exit_interface:
    ldx     #$05
    jsr     printToFirmDisplay
@wait_key_for_exit:    
    BRK_TELEMON XRDW0 
    cmp     #13
    beq     @exit_interface_confirmed
    cmp     #$08
   
    bne     @wait_key_for_exit
    jsr     twil_interface_clear_menu

    lda     #$01
    jsr     twil_interface_change_menu    
    
    dec     twil_interface_current_menu

    lda     #$00
    jsr     twil_interface_change_menu

    jmp     twilfirm_menu_management



@exit_interface_confirmed:    
    ; restore chars 
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE
    lda     #$01
    rts

@display_menu_bank:
    jsr     twil_menu_bank
    lda     #$00
    rts

@display_menu_upgrade_from_clock:
    jsr     twil_interface_change_menu
    dec     twil_interface_current_menu         
    jsr     twil_interface_change_menu
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

.include "../twilconf/infos_menu/twil_menu_infos.s"
.include "../twilconf/memory_menu/_twil_displays_banks.s"
.include "../twilconf/clock_menu/_twil_menu_clock.s"

.include "../twilconf/twil_interface_vars.s"
.include "../common/twil_interface_init.s"
.include "../twilconf/twil_interface_change_menu.s"
.include "../twilconf/twil_interface_clear_menu.s"


.include "../twilconf/displayTwilighteBanner.s"
.include "../common/displayFrame.s"
.include "../common/blitIcon.s"
.include "../common/doscrollupinframe.s"
.include "../common/doscrolldowninframe.s"



str_would_you_like_to_exit:
    .asciiz "Press enter to return to shell"

str_twilighte_firmware_version:
    .asciiz "Firmware version     : "    
str_default_storage:
    .asciiz "Default storage      : "
str_usb_controller_firmware:
    .asciiz "Usb firmware version : "    
str_cpu:
    .asciiz "CPU                  : "
str_microdisc_register:
    .asciiz "Microdisc register   : Yes"
str_twilighte_rtc:
    .asciiz "Real Time Clock      : Yes"    
str_twilighte_battery:
    .asciiz "On board battery     : Yes"    
str_twilighte_battery_level:
    .asciiz "Battery level        : " 
str_twilighte_low:
    .byt $01
    .byt  "Low"
    .byte $07,0
str_twilighte_full:
    .byt "Full"
    .byte 0
str_twilighte_date:
    .asciiz "Date : "
str_twilighte_time:
    .asciiz "Time : "    
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
    .byte   <str_twilighte_date             ; 9
    .byte   <str_twilighte_low              ; 10
    .byte   <str_twilighte_full             ; 11
    .byte   <str_usb_controller_firmware    ; 12
    .byte   <str_twilighte_time             ; 13

        

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
    .byte   >str_twilighte_date
    .byte   >str_twilighte_low              ; 10
    .byte   >str_twilighte_full             ; 11
    .byte   >str_usb_controller_firmware    ; 12
    .byte   >str_twilighte_time             ; 13

pos_string_low:
    .byte   <($BB80+40*7+2)  ; FIRMWARE
    .byte   <($BB80+40*9+2)  ; Default storage
    .byte   <($BB80+40*8+2)  ; CPU
    .byte   <($BB80+40*11+2) ; Microdisc register
    .byte   <($BB80+40*14+2) ; RTC
    .byte   <($BB80+40*7+2)  ; Exit
    .byte   <($BB80+40*7+2)  ; IP
    .byte   <($BB80+40*12+2) ; on board battery
    .byte   <($BB80+40*13+2) ; Battery level
    .byte   <($BB80+40*7+2)  ; Date
    .byte   <($BB80+40*13+25) ; State battery low
    .byte   <($BB80+40*13+25) ; state battery full
    .byte   <($BB80+40*10+2)  ; usb version
    .byte   <($BB80+40*7+2)   ; Time


pos_string_high:
    .byte   >($BB80+40*7+2)
    .byte   >($BB80+40*9+2)
    .byte   >($BB80+40*8+2)
    .byte   >($BB80+40*11+2)
    .byte   >($BB80+40*14+2)  ; RTC
    .byte   >($BB80+40*7+2)   ; Exit
    .byte   >($BB80+40*7+2)   ; Firmware
    .byte   >($BB80+40*12+2)  ; on board battery
    .byte   >($BB80+40*13+2)  ; Battery level
    .byte   >($BB80+40*7+2)   ; Date
    .byte   >($BB80+40*13+25) ; State battery low
    .byte   >($BB80+40*13+25) ; state battery full
    .byte   >($BB80+40*10+2)  ; usb version
    .byte   >($BB80+40*7+2)   ; Time

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

