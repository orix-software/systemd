.proc loader_display_informations



    malloc 50,ptr8
    cmp     #$00
    bne     @nooom
    cpy     #$00
    bne     @nooom

    rts
@nooom:
    sta     ptr8
    sty     ptr8+1

    ; Concat path + letter + key from db file + .md

    lda     #<path_loader_hlp
    sta     ptr5

    lda     #>path_loader_hlp
    sta     ptr5+1

    strncpy ptr5, ptr8, #20

; Looking for letter
    ldy     #$00
    lda     (index_software_ptr),y
    sta     @L2+1
    sta     @L3+1
    sta     @L4+1

    iny
    lda     (index_software_ptr),y
    sta     @L2+2
    sta     @L3+2
    sta     @L4+2

    ; $553F ; Index software
    ; list index : 5041-5351
  ;  jsr     exit_interface_confirmed
 ;   jsr     _debug_lsmem

;@me:
   ; jmp     @me

    ; Search letter from filename

    ldy     #$00
@L2:
    lda     $dead,y
    cmp     #';'
    beq     @end_tape_file
    iny
    bne     @L2
@end_tape_file:
    iny     ; Skip ;
    ; now we get the first letter
@L3:
    lda     $dead,y
    sta     letter+1 ; Store in letter

    lda     #<(letter)
    sta     ptr5

    lda     #>(letter)
    sta     ptr5+1

    strncat ptr5, ptr8 , #13

    ldy     #$00
@L12:
    lda     (ptr8),y
    beq     @EOS_FOUND ; Search the end of str
    iny
    bne     @L12

@EOS_FOUND:
    ; Now concat with the key (at the beginning of the line)
    ldx     #$00
@L4:
    lda     $dead,x
    beq     @out2
    cmp     #'.'
    beq     @out2
    sta     (ptr8),y
    iny
    inx
    jmp     @L4

@out2:
    ; add ".md" to the screen
    lda     #'.'
    sta     (ptr8),y

    iny
    lda     #'m'
    sta     (ptr8),y

    iny
    lda     #'d'
    sta     (ptr8),y

    iny
    lda     #$00
    sta     (ptr8),y


    fopen (ptr8), O_RDONLY
    cpx     #$FF
    bne     @read_hlp ; not null then  start because we did not found a conf
    cmp     #$FF
    bne     @read_hlp
    ; Return and don't generate errors


    mfree (ptr8)
    rts

@read_hlp:
    sta     @fp_info
    sta     ptr5

    stx     @fp_info+1
    stx     ptr5+1
    mfree (ptr8)


    ; Get size
    lda     #CH376_GET_FILE_SIZE
    sta     CH376_COMMAND
    lda     #$68
    sta     CH376_DATA
    ; store file length

    lda     CH376_DATA
    sta     filesize
    sta     filesize_bkp
    ldy     CH376_DATA
    sty     filesize+1
    sty     filesize_bkp+1
    ; and drop others (max 64KB of file)
    ldx     CH376_DATA
    ldx     CH376_DATA

    ; Add One KB to store screen
    iny
    iny
    iny
    iny

    sta     ptr_screen_saved     ; Save the length in order to compute after
    sty     ptr_screen_saved+1

    sta     ptr_screen_saved_bkp     ; Save the length in order to compute after
    sty     ptr_screen_saved_bkp+1

    BRK_KERNEL XMALLOC ; Allocate the size if the file
    cmp     #$00
    bne     @continue_file_information
    cpy     #$00
    beq     @exit_informations

@continue_file_information:

    sta     ptr8
    sta     ptr6 ; Save ptr because we modify on the fly ptr8
    sty     ptr8+1
    sty     ptr6+1 ; Save ptr because we modify on the fly ptr8

    fread (ptr8), filesize, 1, ptr5

    fclose (ptr5)

    jsr     @information_screen_save

    lda     #$01
    sta     @EOF

@read_page:

    ; Init text position
    lda     #<(LOADER_POSITION_START_INFORMATION)
    sta     @position_text+1
    lda     #>(LOADER_POSITION_START_INFORMATION)
    sta     @position_text+2

    lda     #$00
    sta     @pos_y

    jsr     twil_interface_clear_menu


    ldy     #$00
@L10:
    lda     (ptr8),y
    cmp     #'#'  ; SOftware Title ?
    beq     @do_title
    cmp     #$0A
    beq     @update_pos
    cmp     #$0D
    beq     @update_pos
@position_text:
    sta     LOADER_POSITION_START_INFORMATION,y

    cpy     #LOADER_MAX_LENGTH_SOFTWARE_NAME
    beq     @update_pos

    iny

@continue_after_compute:
    lda     filesize
    bne     @dec_low_only
    dec     filesize+1
@dec_low_only:
    dec     filesize

    lda     @pos_y    ; Are we on the last text line ?
    cmp     #LOADER_MAX_LINE_FOR_INFORMATION_TEXT
    beq     @read_keyboard

    lda     filesize
    bne     @L10

    lda     filesize+1
    bne     @L10

    lda     #$00
    sta     @EOF
    jmp     @read_keyboard

@do_title:
    lda     #$07
    sta     LOADER_FIRST_POSITION_BAR+37
    lda     #$06
    jmp     @position_text
@exit_informations:
    mfree (ptr6)
    jsr     twil_interface_clear_menu
    jsr     @information_screen_restore

    rts

@read_keyboard:
    BRK_KERNEL XRDW0
    cmp     #TWIL_KEYBOARD_ESC
    beq     @exit_informations
    cmp     #10 ; down
    beq     @go_down
    cmp     #11 ; up
    beq     @go_up
    cmp     #$08
    beq     @exit_informations
    cmp     #$09
    beq     @exit_informations
    bne     @read_keyboard
    rts

@update_pos:
    lda     @position_text+1
    clc
    adc     #$28
    bcc     @do_not_inc
    inc     @position_text+2
@do_not_inc:
    sta     @position_text+1

    iny
    tya
    clc
    adc     ptr8
    bcc     @do_not_inc2
    inc     ptr8+1
@do_not_inc2:
    sta     ptr8

    inc     @pos_y

    ldy     #$00

    jmp     @continue_after_compute

@go_down:
    lda     @EOF             ; EOF ?
    beq     @read_keyboard   ; yes we can't go down
    jmp     @read_page
    rts

@go_up:
    lda     filesize_bkp
    sta     filesize

    lda     filesize_bkp+1
    sta     filesize+1

    lda     ptr6+1
    sta     ptr8+1

    lda     ptr6
    sta     ptr8

    lda     #$01
    sta     @EOF

    jmp     @read_page

    lda     ptr6
    cmp     ptr8
    bne     @not_beginning_of_file
    lda     ptr6+1
    cmp     ptr8+1
    bne     @not_beginning_of_file
    beq     @read_keyboard   ; yes we can't go up

    lda     #<(LOADER_NUMBER_OF_BYTE_FOR_SCROLLING_AND_INFORMATION_TEXT)
    sec
    sbc     ptr8
    bne     @do_not_dec
    dec     ptr8+1
@do_not_dec:
    sta     ptr8

    lda     #>(LOADER_NUMBER_OF_BYTE_FOR_SCROLLING_AND_INFORMATION_TEXT)
    sec
    sbc     ptr8+1
    sta     ptr8+1
    ; go up

@not_beginning_of_file:
    jmp     @read_page

@information_screen_save:

    lda     #<(LOADER_POSITION_START_INFORMATION_ATTRIBUTE)
    sta     @L30+1

    lda     #>(LOADER_POSITION_START_INFORMATION_ATTRIBUTE)
    sta     @L30+2

    lda     ptr6+1
    clc
    adc     filesize_bkp+1
    sta     ptr_screen_saved+1
    sta     ptr_screen_saved_bkp+1


    lda     ptr6
    clc
    adc     filesize_bkp
    bcc     @no_inc
    inc     ptr_screen_saved+1
    inc     ptr_screen_saved_bkp+1
@no_inc:
    sta     ptr_screen_saved
    sta     ptr_screen_saved_bkp

    ; now save

    ldx     #$00

    lda     ptr_screen_saved
    sta     ptr7

    lda     ptr_screen_saved+1
    sta     ptr7+1

    ldy     #$00
@L30:
    lda     LOADER_POSITION_START_INFORMATION,y
    sta     (ptr7),y
    iny
    bne     @L30
    inc     ptr7+1
    inc     @L30+2
    inx
    cpx     #$04
    bne     @L30

    rts

@information_screen_restore:

    lda     #<(LOADER_POSITION_START_INFORMATION_ATTRIBUTE)
    sta     @L31+1

    lda     #>(LOADER_POSITION_START_INFORMATION_ATTRIBUTE)
    sta     @L31+2

    lda     ptr_screen_saved_bkp
    sta     ptr7
    lda     ptr_screen_saved_bkp+1
    sta     ptr7+1

    ldy     #$00
@L32:
    lda     (ptr7),y
@L31:
    sta     LOADER_POSITION_START_INFORMATION,y
    iny
    bne     @L32
    inc     ptr7+1
    inc     @L31+2
    inx
    cpx     #$04
    bne     @L32

    rts


@pos_y:
    .res 1
@fp_info:
    .res 1
@EOF:   ; Store EOS
    .res 1
filesize:
    .res 2
filesize_bkp:
    .res 2
ptr_screen_saved:
    .res 2
ptr_screen_saved_bkp:
    .res 2

.endproc

path_loader_hlp:
    .asciiz "/usr/share/loader"
letter:
    .asciiz "/X/"