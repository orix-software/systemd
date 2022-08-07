.proc config_menu
    ldx     #$06
    jsr     printToFirmDisplay
    lda     #$00
    sta     line_conf_current

    jsr     display_option_line



loop_key:
    cgetc key
 ;   cmp     #KEY_ESC
  ;  beq     exit_config_with_exit
   ; cmp     #KEY_RIGHT
   ; beq     exit_config
   ; cmp     #KEY_LEFT
   ; beq     exit_config
	do_case	key
	;	case_of KEY_LEFT, backward_char
	;	case_of KEY_RIGHT, right
	;	case_of KEY_UP, get_history_up
		case_of KEY_DOWN, enter_list
	;	case_of KEY_RETURN, accept_line
	;	case_of KEY_ESC, exit_config
		;otherwise key_others
    end_case
    lda     key ; return keys
    rts

display_option_line:

    ldx     #$00
    lda     config_line_config_low,x
    sta     @test_conf+1
    lda     config_line_config_high,x
    sta     @test_conf+2

@test_conf:
    lda     $dead
    beq     @disabled

    lda     #<str_enabled
    sta     RES
    lda     #>str_enabled
    sta     RES+1
    jmp     @display

@disabled:
    lda     #<str_disabled
    sta     RES
    lda     #>str_disabled
    sta     RES+1

@display:
    ldx     #$00 ; Line  config
    lda     position_options_low,x
    sta     RESB
    lda     position_options_high,x
    sta     RESB+1

    jsr     display_option
    rts

exit_config_with_exit:
    lda     #$01
    rts

exit_config:
    lda     #$00
    rts

left:
right:

    lda     shell_extension_at_boot
    beq     @save_enabled
    lda     #$00
    sta     shell_extension_at_boot

    jmp     @continue_right

@save_enabled:

    inc     shell_extension_at_boot

@continue_right:

    jsr     display_option_line

    jmp     loop_key_config


enter_list:
    lda     #$04
    jsr     switch_color

loop_key_config:
    cgetc key
    lda     key
    cmp     #KEY_ESC
    beq     exit_list
    lda     key
    cmp     #KEY_UP
    beq     exit_list
	do_case	key
		case_of KEY_LEFT, left
		case_of KEY_RIGHT, right
		;case_of KEY_UP
         ;   rts
		case_of KEY_DOWN, down
	;	case_of KEY_RETURN, accept_line
		;otherwise key_others
    end_case
    jmp     loop_key_config

exit_list:
    lda     #$07
    jsr     switch_color
    lda     #$01
    rts

switch_color:
    pha
    lda     position_options_high
    sta     __switch_off+2

    lda     position_options_low
    sec
    sbc     #$01
    bne     @do_not_dec
    dec     __switch_off+2
@do_not_dec:
    sta     __switch_off+1

    pla
__switch_off:
    sta     $dead
    rts


down:



    jmp     loop_key_config
display_option:
    ldy     #$00
@L1:
    lda     (RES),y
    beq     @out
    sta     (RESB),y
    iny
    bne     @L1
@out:
    rts
line_conf_current:
    .res 1
key:
    .res 1
str_enabled:
    .byte "Enabled",$07,0
str_disabled:
    .byte "Disabled",$07,0
position_options_low:
    .byte <($bb80+7*40+25) ; shell_extentions
position_options_high:
    .byte >($bb80+7*40+25) ; shell_extentions
config_path:
    .asciiz "/etc/systemd/orix.cnf"
config_line_config_low:
    .byte <shell_extension_at_boot
config_line_config_high:
    .byte >shell_extension_at_boot

.endproc

