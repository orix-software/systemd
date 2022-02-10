.export _loader

.define LOADER_COLOR_BAR                $11
.define LOADER_CONF_SEPARATOR           ';'
.define LOADER_MAX_SIZE_DB_SIZE         25000 
.define LOADER_FIRST_POSITION_BAR       $bb80+7*40+1
.define LOADER_LAST_LINE_MENU_ITEM      18
.define LOADER_MAX_SOFTWARE_BY_CATEGORY 2000
.define LOADER_LAST_LINE                $bb80+24*40+1
.define LOADER_MAX_LENGTH_SOFTWARE_NAME 35
.define LOADER_POS_INF_NUMBER           $bb80+27*40

; Number of malloc here :
; Routine loaded to load systemd.rom
; file content db
; Struct process
; routine to load


; Don't use userzp+4 !!! It's a malloc for return routine in twilbank of shell command (when funct + T and funct +L are pressed)

ptr1_loader         := userzp+6
ptr2_loader         := userzp+8
ptr3_loader         := userzp+10
index_software      := userzp+12 ; Table which contains the ptr of each software
id_current_software := userzp+14 ; Word
index_software_ptr  := userzp+16 ; ptr computre



.proc _loader
    cli

    lda     #$00
    sta     pos_menu_loader_x
    sta     software_menu_id

    ldx     #$01 ; Loader banner
    jsr     twil_interface_init

    ldx     #TWIL_ICON_ROM_ID
    jsr     _blitIcon

    ldx     #TWIL_ICON_DEMO
    jsr     _blitIcon

    ldx     #TWIL_ICON_GAME
    jsr     _blitIcon

    ldx     #TWIL_ICON_TOOLS
    jsr     _blitIcon

    ldx     #TWIL_ICON_EXIT_LOADER
    jsr     _blitIcon

    ldx     #TWIL_ICON_MUSIC_LOADER
    jsr     _blitIcon


@start_menu_bank:
    jsr     twil_interface_clear_menu
    jsr     _start_twilmenubank
    cmp     #$01 ; Error does not clear screen
    beq     @exit_loader
    cmp     #TWIL_KEYBOARD_ESC
    beq     @exit_loader
    ldx     pos_menu_loader_x
    inx
    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @demo_menu

@exit_loader:
    jmp     exit_interface_confirmed  

@demo_menu:
    lda     #$00
    sta     software_menu_id

    lda     #$00
    sta     twil_interface_current_menu   

    lda     #TWIL_SWITCH_ON_ICON
    jsr     twil_interface_change_menu
    jsr     twil_interface_clear_menu

    jsr     @display_menu_loader_software
    
    cmp     #TWIL_KEYBOARD_ESC
    beq     @exit_loader

    cmp     #TWIL_KEYBOARD_LEFT
    beq     @switch_to_menu_bank

    cmp     #TWIL_KEYBOARD_RIGHT
    bne     @check_right_demo
    inc     twil_interface_current_menu
    jmp     @game_menu
@switch_to_menu_bank:
    lda     #TWIL_SWITCH_OFF_ICON
    jsr     twil_interface_change_menu
    jmp     @start_menu_bank 
@check_right_demo:    


@check_right:    
    cmp     #TWIL_KEYBOARD_ESC

    rts    
@game_menu:
    lda     #$01
    sta     software_menu_id
    
    lda     #$04
    sta     twil_interface_current_menu    
    lda     #$01
    jsr     twil_interface_change_menu

    jsr     twil_interface_clear_menu
    jsr     @display_menu_loader_software

    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @check_right_game
    cmp     #TWIL_KEYBOARD_LEFT
    beq     @check_left_game
    
    
    cmp     #TWIL_KEYBOARD_ESC
   
    beq     @exit_loader


    inc     twil_interface_current_menu
    jmp     @tools_menu

@check_right_game:    
    inc     twil_interface_current_menu
    jmp     @tools_menu    
@check_left_game:    
    lda     #TWIL_SWITCH_OFF_ICON
    jsr     twil_interface_change_menu

    jmp     @demo_menu    
  

@tools_menu:
    lda     #$02
    sta     software_menu_id
    lda     #$03
    sta     twil_interface_current_menu
    lda     #$01
    jsr     twil_interface_change_menu



    jsr     twil_interface_clear_menu
    jsr     @display_menu_loader_software
    
    cmp     #TWIL_KEYBOARD_ESC
    bne     @go_to_next_menu_tools
    jmp     @exit_loader

@go_to_next_menu_tools:

    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @music_menu
    cmp     #TWIL_KEYBOARD_LEFT
    bne     @check_esc_tools_menu 


    lda     #$00
    jsr     twil_interface_change_menu

    
    jmp     @game_menu




@music_menu:
    lda     #$03
    sta     software_menu_id
    lda     #$05
    sta     twil_interface_current_menu
    lda     #$01
    jsr     twil_interface_change_menu



    jsr     twil_interface_clear_menu
    jsr     @display_menu_loader_software
    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @exit_menu 

    cmp     #TWIL_KEYBOARD_ESC
    bne     @go_to_next_menu_music
    jmp     @exit_loader


@go_to_next_menu_music:

    cmp     #TWIL_KEYBOARD_LEFT
    bne     @check_esc_tools_menu 
    


    lda     #$00
    jsr     twil_interface_change_menu
    
    jmp     @tools_menu
    
@check_esc_tools_menu:   

    rts        
@exit_menu:
    jsr     _loader_clear_bottom_text
    jsr     twil_interface_clear_menu
    lda     #TWIL_ICON_MUSIC_LOADER
    sta     twil_interface_current_menu

    lda     #$01
    jsr     twil_interface_change_menu
    lda     #TWIL_ICON_EXIT_LOADER
    sta     twil_interface_current_menu    
    lda     #$00
    jsr     twil_interface_change_menu

    

    
@exit_interface:
    ldx     #$05
    jsr     printToFirmDisplay
@read_key_exit:    
    BRK_TELEMON XRDW0 
    cmp     #13
    beq     @jmp_exit_interface_confirmed
    cmp     #08
    beq     @switch_off_exit_icon_and_jump_to_tools
    jmp     @read_key_exit

@switch_off_exit_icon_and_jump_to_tools:
    lda     #$0C
    sta     twil_interface_current_menu    
    lda     #$01
    jsr     twil_interface_change_menu

    jmp     @music_menu

@jmp_exit_interface_confirmed:
    jmp 	exit_interface_confirmed


@display_twil_menu_bank:
    lda     #$01
    jsr     twil_interface_change_menu
    dec     twil_interface_current_menu
    
    jsr     twil_interface_clear_menu

    lda     #$00
    jsr     twil_interface_change_menu 

    jmp     @start_menu_bank 

@display_menu_loader_software:

    ;strncpy(src, dest, n)
;
; Sortie:
;        A: 0 et Z=1 si copie effectuée, inchangé si non
;        X: 0
;        Y: Longueur réellement copiée
    malloc 40,ptr1
    cmp     #$00
    bne     @not_oom
    cpy     #$00
    bne     @not_oom
    ; FIX OOM
    lda     #TWIL_KEYBOARD_ESC
    jsr     exit_interface_confirmed
    print   str_oom,NOSAVE
    rts

@not_oom:
    sta     ptr2
    sty     ptr2+1 ; Save ptr


    lda     #<file_path
    sta     RESB    
    lda     #>file_path
    sta     RESB+1

    strncpy RESB, ptr1, #20 ;strncpy(src, dest, n)

    ldx     software_menu_id
    lda     files_type_loader_low,x
    sta     RESB    
    lda     files_type_loader_high,x
    sta     RESB+1


    strncat RESB, ptr1 , #13

    ldy     #$00
@L100:    
    lda     (ptr2),y
    beq     @out_demo
    
    iny     
    bne     @L100

@out_demo:
    ; Fopen now
    fopen (ptr2), O_RDONLY
    cpx     #$FF
    bne     @read_db ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read_db ; not null then  start because we did not found a conf
    jsr     exit_interface_confirmed
    
    print   (ptr2),NOSAVE
    print   str_not_found,NOSAVE
    mfree   (ptr2)
    BRK_KERNEL XCRLF
    
    lda     #$FF
    ldx     #$FF
    rts
@read_db:
    sta     fp_file_menu
    stx     fp_file_menu+1

    mfree   (ptr2)
    
    malloc  #LOADER_MAX_SIZE_DB_SIZE,ptr2 ; 20000 bytes
    cmp     #$00
    bne     @not_oom_file_content
    cpy     #$00
    bne     @not_oom_file_content
    ; FIX OOM
    
    jsr     exit_interface_confirmed ; Return in A last ascii code of the keyboard
    print   str_oom,NOSAVE
    rts

@not_oom_file_content:


    fread (ptr2), LOADER_MAX_SIZE_DB_SIZE, 1, fp_file_menu
    fclose(fp_file_menu)


    jsr     display_list  ; Return in A last ascii code of the keyboard
    pha
    mfree(index_software)
    mfree(ptr2)
;    jsr     _debug_lsmem
  
    pla
    rts
.endproc

.proc exit_interface_confirmed
    cmp     #$01 ; Error and screen already clear ?
    beq     @out      ; Yes
	BRK_KERNEL XHIRES ; Hires
	BRK_KERNEL XTEXT  ; and text
	BRK_KERNEL XSCRNE
@out:    
    rts
.endproc

.proc display_list
    lda     #$00
 
    sta     id_current_software
    sta     id_current_software+1
    sta     reached_bottom_of_screen

    lda     #$00
    sta     pos_y_listing

    lda     #<(LOADER_FIRST_POSITION_BAR)
    sta     pos_bar
    lda     #>(LOADER_FIRST_POSITION_BAR)
    sta     pos_bar+1

    lda     #<(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3
    lda     #>(LOADER_FIRST_POSITION_BAR+1)
    sta     ptr3+1

    lda     ptr2
    sta     ptr1
    lda     ptr2+1
    sta     ptr1+1
    
    ; Get the number if the softare
    ldy     #$02 ; First byte is the version, second byte and third are the number of software
    lda     (ptr1),y
    sta     nb_of_software+1
    tax     ; save High for malloc

    dey
    lda     (ptr1),y
    sta     nb_of_software

    asl 
    bcc     @do_not_inc_x
    inx
@do_not_inc_x:
    ; At this step we have the number of software*2
    ; Swap X and Y

    stx     loader_tmp1
    ldy     loader_tmp1
    ; Now malloc 


    BRK_KERNEL XMALLOC
    cmp     #$00
    bne     @not_oom_for_ptr4
    cpy     #$00
    bne     @not_oom_for_ptr4
    mfree(ptr2)
    jsr     exit_interface_confirmed
    print   str_oom,NOSAVE
    rts
    
@not_oom_for_ptr4:    
    sta     index_software

    sty     index_software+1

    sta     index_software_ptr
    sty     index_software_ptr+1

    ; Id current software used to build the software table
    lda     #$00
    sta     id_current_software
    sta     id_current_software+1

    ; compute ptr1 with the header
    
    ; Init ptr with the first entry

    lda     ptr1
    clc
    adc     #$03            ; Add 3 because there is 3 bytes in the db header (Db version, number of software : 16 bits)
    bcc     @no_inc_ptr1
    inc     ptr1+1
@no_inc_ptr1:
    sta     ptr1    

    
    ldy     #$00
    lda     ptr1
    sta     (index_software_ptr),y
    
    iny
    lda     ptr1+1
    sta     (index_software_ptr),y
    


   ; Inc +2
    inc     index_software_ptr
    bne     @skipinc3
    inc     index_software_ptr+1
@skipinc3:

    inc     index_software_ptr
    bne     @skipinc4
    inc     index_software_ptr+1
@skipinc4:


@S30:

@init_Y:


    ldy     #$00 ; First byte is the version, second byte and third are the number of software
@loop:    
    lda     (ptr1),y
    beq     @next_software
    cmp     #$FF ; EOF 
    beq     @start_nav
    cmp     #';'
    beq     @software_name_found
    iny
    bne     @loop
@next_software:
    sty     tmp_Y





; Compute ptr
    ldy     tmp_Y
    iny
    tya
    clc
    adc     ptr1
    bcc     @no_compute_inc
    inc     ptr1+1
@no_compute_inc:
    sta     ptr1


    ldy     #$00    
    lda     ptr1
    sta     (index_software_ptr),y
    iny
    lda     ptr1+1
    sta     (index_software_ptr),y
 

   ; Inc +2
    inc     index_software_ptr
    bne     @skipinc1
    inc     index_software_ptr+1
@skipinc1:

    inc     index_software_ptr
    bne     @skipinc2
    inc     index_software_ptr+1
@skipinc2:


    inc     id_current_software 
    bne     @do_not_inc_id_current_software
    inc     id_current_software+1 
@do_not_inc_id_current_software:

    jmp     @init_Y
    
    

    ; New software

    

   

@out:
    rts
@start_nav:
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar
    lda     #$00
    sta     id_current_software
    sta     id_current_software+1

    lda     index_software
    sta     index_software_ptr

    lda     index_software+1
    sta     index_software_ptr+1


@wait_keyboard:
    jsr     debug_loader   
    
    BRK_KERNEL XRDW0
    cmp     #TWIL_KEYBOARD_LEFT
    beq     @exit_listing
    cmp     #TWIL_KEYBOARD_RIGHT
    beq     @exit_listing
    cmp     #TWIL_KEYBOARD_ESC
    beq     @exit_listing
    cmp     #10
    beq     @go_down        
    cmp     #11
    beq     @go_up
    cmp     #13
    beq     @go_enter    
    jmp     @wait_keyboard

@exit_listing:
    rts    
@go_enter:
    jmp     _loader_launch_software
@go_down:
    ; compute if we reached the number of software
    ;nb_of_software

    jmp     @go_down_routine


@go_up:
    jmp     @go_up_routine



@software_name_found:
    iny
    tya
    clc
    adc     ptr1
    bcc     @S1
    inc     ptr1+1
@S1:        
    sta     ptr1

    ldy     #$00
@loop2:    

    lda     (ptr1),y
    cmp     #LOADER_CONF_SEPARATOR ; Is it ';' ?
    beq     @exit


    ldx     reached_bottom_of_screen
    cpx     #LOADER_LAST_LINE_MENU_ITEM
    beq     @no_display_software


    sta     (ptr3),y
@no_display_software:      
    iny
    bne     @loop2


@exit:
    ; skip flags

    lda     ptr3
    clc     
    adc     #$28
    bcc     @S13
    inc     ptr3+1
@S13:
    sta     ptr3

@L20:  

    iny
    lda     (ptr1),y

    beq     @end_of_software_line
    
    bne     @L20

@end_of_software_line:
    lda     reached_bottom_of_screen
    cmp     #LOADER_LAST_LINE_MENU_ITEM
    beq     @skip_inc_reached_bottom_of_screen
    inc     reached_bottom_of_screen
@skip_inc_reached_bottom_of_screen:


@do_not_inc:    

    jmp     @loop




@go_down_routine:
    jsr     loader_check_max_software
    jmp     @wait_keyboard



@go_up_routine:
    ; Does the bar is at the first line ?



@check_pos:
    lda     pos_y_listing
    beq     @skip_bar
    lda     #$10
    jsr     loader_display_bar

    dec     pos_y_listing
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar

; Inc +2
    lda     index_software_ptr
    bne     @skipinc1_up
    dec     index_software_ptr+1
@skipinc1_up:
    dec     index_software_ptr

    lda     index_software_ptr
    bne     @skipinc2_up
    dec     index_software_ptr+1
@skipinc2_up:
    dec     index_software_ptr


    lda     id_current_software
    bne     @skip_dec_high
    dec     id_current_software+1
@skip_dec_high:
    dec     id_current_software


@skip_bar:
    lda     pos_y_listing
    bne     @exit_up   


    lda     id_current_software+1
    beq     @check_id_0_software
    jmp     @doscroll

@check_id_0_software:
    lda     id_current_software
    beq     @exit_up
    
    ;; No it's not the first software in the db, do scroll now
@doscroll:
    lda     #$10
    jsr     loader_display_bar


    jsr     doscrolldowninframe
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar    


    lda     id_current_software
    bne     @skip_dec_high3
    dec     id_current_software+1
@skip_dec_high3:
    dec     id_current_software

   ; dec -2
    lda     index_software_ptr
    bne     @do_not_inc_ptr_high
    dec     index_software_ptr+1
@do_not_inc_ptr_high:    
    dec     index_software_ptr

    lda     index_software_ptr
    bne     @do_not_inc_ptr_high2
    dec     index_software_ptr+1
@do_not_inc_ptr_high2:    
    dec     index_software_ptr



    jsr     loader_display_software
    jmp     @exit_up


@dec_id_current_software:
    lda     id_current_software
    bne     @skip_dec_high2
    dec     id_current_software+1
@skip_dec_high2:
    dec     id_current_software
@exit_up:
    jmp     @wait_keyboard

.endproc

.proc debug_loader

    lda     #<(LOADER_POS_INF_NUMBER)
    sta     TR5
    lda     #>(LOADER_POS_INF_NUMBER)
    sta     TR5+1

    lda     #$20
    sta     DEFAFF

    ldx     #$01
    ldy     id_current_software+1
    
    lda     id_current_software
    clc
    adc     #$01
    bcc     @S1
    iny
@S1:    
    BRK_KERNEL XBINDX

    lda     #'/'
    sta     LOADER_POS_INF_NUMBER+3


    lda     #<(LOADER_POS_INF_NUMBER+4)
    sta     TR5
    lda     #>(LOADER_POS_INF_NUMBER+4)
    sta     TR5+1

    lda     #$20
    sta     DEFAFF

    ldx     #$01
    ldy     nb_of_software+1
    lda     nb_of_software
    BRK_KERNEL XBINDX    

    rts
.endproc

.proc loader_check_max_software
 
    lda     id_current_software+1
    cmp     nb_of_software+1
    bne     @skip

    ldx     id_current_software
    inx
    cpx     nb_of_software
    bne     @skip
    rts

@skip:


 ; Inc +2
    inc     index_software_ptr
    bne     @skipinc1
    inc     index_software_ptr+1
@skipinc1:

    inc     index_software_ptr
    bne     @skipinc2
    inc     index_software_ptr+1
@skipinc2:

 
    lda     pos_y_listing
    cmp     #(LOADER_LAST_LINE_MENU_ITEM-1)
    bne     @change_bar
    ; switch off bar


    lda     #$10
    jsr     loader_display_bar

    jsr     doscrollupinframe

    ; Display next software

    ldy     #$00
    lda     (index_software_ptr),y
    sta     @L33+1
    sta     @get_char+1
    iny
    lda     (index_software_ptr),y
    sta     @L33+2
    sta     @get_char+2


    ldy     #$00
@L33:    
    lda     $dead,y
    beq     @out33
    cmp     #';'
    beq     @tape_file_found
    iny
    bne     @L33
    
    ldx     #$01
@tape_file_found:
    iny

@get_char:    
    lda     $dead,y
    beq     @out33
    cmp     #';'
    beq     @out33
    cpx     #LOADER_MAX_LENGTH_SOFTWARE_NAME
    beq     @exit_diplay
    sta     LOADER_LAST_LINE+1,x
    inx

    jmp     @tape_file_found
@exit_diplay:

    ; bla
@out33:
    ; Switch on bar
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar
    jmp     @inc_current

@change_bar:
    lda     #$10
    jsr     loader_display_bar
    inc     pos_y_listing
    lda     #LOADER_COLOR_BAR
    jsr     loader_display_bar

@inc_current:
    inc     id_current_software
    bne     @no_inc_current
    inc     id_current_software+1
@no_inc_current:
    rts
.endproc



.proc loader_display_bar
    pha
  
    ldx     pos_bar
    stx     display+1
    ldx     pos_bar+1
    stx     display+2

    ldx     pos_y_listing
    beq     @out

@still_compute:    
    lda     display+1
    clc
    adc     #$28
    bcc     @S1
    inc     display+2
@S1:    
    sta     display+1
    dex
    bne     @still_compute


@out:
    pla
display:    
    sta     $dead
    rts
.endproc

.proc loader_display_software
    sta     mode
    ; Display next software

    ldy     #$00
    lda     (index_software_ptr),y
    sta     @L33+1
    sta     @get_char+1
    iny
    lda     (index_software_ptr),y
    sta     @L33+2
    sta     @get_char+2


    ldy     #$00
@L33:    
    lda     $dead,y
    beq     @out33
    cmp     #';'
    beq     @tape_file_found
    iny
    bne     @L33
    
    ldx     #$01
@tape_file_found:
    iny

@get_char:    
    lda     $dead,y
    beq     @out33
    cmp     #';'
    beq     @out33
    cpx     #LOADER_MAX_LENGTH_SOFTWARE_NAME
    beq     @exit_diplay
    sta     LOADER_FIRST_POSITION_BAR+1,x
    inx

    jmp     @tape_file_found
@exit_diplay:
@out33:
    rts
mode:
    .res 1        
.endproc

.data
tmp_Y:
    .res 1
pos_y_listing:
    .byte 0
pos_bar:
    .byte 0,0
nb_of_software:
    .byte 0,0
reached_bottom_of_screen:
    .byte 0
;Position of the current icon (ROM excluded)
software_menu_id:
    .byte 0
fp_file_menu:
    .byte 0,0
pos_menu_loader_x:
    .byte 0
files_type_loader_low:
    .byte <file_demo_db
    .byte <file_games_db
    .byte <file_tools_db
    .byte <file_music_db
    .byte <file_unsorted_db

files_type_loader_high:
    .byte >file_demo_db
    .byte >file_games_db
    .byte >file_tools_db
    .byte >file_music_db
    .byte >file_unsorted_db    

file_path:
    .asciiz "/var/cache/loader/"

file_demo_db:
    .asciiz "demos.db"
file_games_db:
    .asciiz "games.db"
file_unsorted_db:
    .asciiz "unsorted.db"
file_tools_db:
    .asciiz "utils.db"
file_music_db:
    .asciiz "music.db"

.include "_loader_launch_software.s"
.include "_loader_clear_bottom_text.s"

