.export _loader

.define LOADER_COLOR_BAR                      $11
.define LOADER_CONF_SEPARATOR                 ';'
.define LOADER_MAX_SIZE_DB_SIZE               25000
.define LOADER_FIRST_POSITION_BAR             $bb80+7*40+1
.define LOADER_LAST_LINE_MENU_ITEM            18
.define LOADER_MAX_SOFTWARE_BY_CATEGORY       2000
.define LOADER_LAST_LINE                      $bb80+24*40+1
.define LOADER_MAX_LENGTH_SOFTWARE_NAME       35
.define LOADER_POS_INF_NUMBER                 $bb80+27*40
.define LOADER_FIRST_BYTE_OFFSET_AFTER_HEADER $02
.define LOADER_POSITION_FOR_VERSION_DISPLAY   $bb80+27*40+33
.define LOADER_POSITION_START_INFORMATION_ATTRIBUTE     $bb80+7*40    ; The first line where information is displayed
.define LOADER_POSITION_START_INFORMATION     LOADER_POSITION_START_INFORMATION_ATTRIBUTE+2    ; The first line where information is displayed

CH376_GET_FILE_SIZE   = $0C

.define LOADER_MAX_LINE_FOR_INFORMATION_TEXT  18
.define LOADER_NUMBER_OF_BYTE_FOR_SCROLLING_AND_INFORMATION_TEXT LOADER_FIRST_POSITION_BAR-$bb80+18*40+39

; Number of malloc here :
; Routine loaded to load systemd.rom
; file content db
; Struct process
; routine to load

; index_software_ptr contains a ptr which contains all offsets of the software



; Don't use userzp+4 !!! It's a malloc for return routine in twilbank of shell command (when funct + T and funct +L are pressed)

ptr1_loader         := userzp+6
ptr2_loader         := userzp+8
ptr3_loader         := userzp+10
index_software      := userzp+12 ; Table which contains the ptr of each software
id_current_software := userzp+14 ; Word
index_software_ptr  := userzp+16 ; ptr compute
tmp1                := userzp+18 ; ptr compute



.proc _loader
    cli

    lda     #$00
    sta     pos_menu_loader_x
    sta     software_menu_id
    sta     software_index_ptr_compute_from_search
    sta     loader_from_search_key

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
    ; Display version
    ldy     #$00
@L1:
    lda     version,y
    beq     @out
    sta     LOADER_POSITION_FOR_VERSION_DISPLAY,y
    iny
    bne     @L1
@out:

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
    sta     loader_from_search_key
    sta     software_index_ptr_compute_from_search

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

    lda     #$00
    sta     loader_from_search_key
    sta     software_index_ptr_compute_from_search

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
    lda     #$00
    sta     loader_from_search_key
    sta     software_index_ptr_compute_from_search

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
    lda     #$00
    sta     loader_from_search_key
    sta     software_index_ptr_compute_from_search

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
    print   str_oom
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

    print   (ptr2)
    print   #' '
    print   str_not_found
    mfree   (ptr2)
    BRK_KERNEL XCRLF

    lda     #$FF
    ldx     #$FF
    rts
@read_db:
    sta     fp_file_menu
    stx     fp_file_menu+1

    mfree   (ptr2)



    ; Get size of tje fome
    lda     #CH376_GET_FILE_SIZE
    sta     CH376_COMMAND
    lda     #$68
    sta     CH376_DATA
    ; store file length

    lda     CH376_DATA
    sta     @filesize

    ldy     CH376_DATA
    sty     @filesize+1

    ; and drop others (max 64KB of file)
    ldx     CH376_DATA
    ldx     CH376_DATA


    BRK_KERNEL XMALLOC
    ;malloc  #LOADER_MAX_SIZE_DB_SIZE,ptr2 ; 20000 bytes
    cmp     #$00
    bne     @not_oom_file_content
    cpy     #$00
    bne     @not_oom_file_content
    ; FIX OOM

    jsr     exit_interface_confirmed ; Return in A last ascii code of the keyboard
    print   str_oom
    rts

@filesize:
    .res 2

@not_oom_file_content:
    sta     ptr2
    sty     ptr2+1

    fread (ptr2), @filesize, 1, fp_file_menu
;    fread (ptr2), LOADER_MAX_SIZE_DB_SIZE, 1, fp_file_menu


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
    ;cpy
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
software_index_ptr_compute_from_search:
    .byte 0
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
loader_from_search_key:
    .byte 0


.include "_loader_launch_software.s"
.include "_loader_clear_bottom_text.s"
.include "loader_search_by_keysearch.s"
.include "display_list.s"
.include "loader_display_informations.s"
