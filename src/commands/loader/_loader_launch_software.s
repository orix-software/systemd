
; A and Y ptr of the conf

.define LOADER_LAUNCH_BASIC11_TAPE_FILE 'A'
.define LOADER_LAUNCH_BASIC10_TAPE_FILE 'O'
.define LOADER_LAUNCH_FTDOS_DISK_FILE   'J'
.define LOADER_LAUNCH_ORIX_BIN_FILE     'Z'
.define LOADER_LAUNCH_SEDORIC_FILE      'S'


.proc _loader_launch_software

    ; Looking for mode index_software_ptr


    ; Search first ; and get tape file
    ldy     #$00
    lda     (index_software_ptr),y
    sta     @L2+1
    sta     @L3+1
    sta     @L302+1
    sta     @get_flag+1

    iny

    lda     (index_software_ptr),y
    sta     @L2+2
    sta     @L3+2
    sta     @L302+2
    sta     @get_flag+2


    ldy     #$00
@L2:
    lda     $dead,y
    cmp     #';'
    beq     @end_tape_file
    cmp     #'.'
    beq     @end_tape_file
    sta     basic11_name_tape_file,y
    iny
    bne     @L2

@end_tape_file:
    lda     #$00 ; end
    sta     basic11_name_tape_file,y


    ; Looking for next ; it's software name now
    iny ; Skip ;
@L3:
    lda     $dead,y
    cmp     #';'
    beq     @end_software_name
    iny
    bne     @L3

@end_software_name:
    iny

    ; Looking for flag now
@L302:
    lda     $dead,y
    cmp     #';'
    beq     @flag_found
    iny
    bne     @L302
@flag_found:
    iny


@get_flag:
    lda     $dead,y
    cmp     #LOADER_LAUNCH_BASIC11_TAPE_FILE
    beq     @start_basic11_tape_file

    cmp     #LOADER_LAUNCH_BASIC10_TAPE_FILE
    beq     @start_basic10_tape_file

    bne     @start_basic11_tape_file ; Default start basic11 if flag is unknown
@start_basic10_tape_file:

    ldy     #$00
@L300:
    lda     basic10_exec_command,y
    sta     basic11_exec_command,y
    iny
    cpy     #$07
    bne     @L300

    beq     @start_command

@start_basic11_tape_file:

    ldy     #$00
@L301:
    lda     basic11_exec_command,y
    sta     basic11_exec_command,y
    iny
    cpy     #$07
    bne     @L301


@start_command:

    ldy     #$00
@L1:
    lda     basic11_exec_command,y
    beq     @out
    sta     BUFEDT,y
    iny
    bne     @L1
@out:
    sta     BUFEDT,y

    mfree   (index_software)
    mfree   (ptr2)

    jsr     exit_interface_confirmed


    lda     #<BUFEDT
    ldy     #>BUFEDT
    BRK_KERNEL XEXEC


    ldy     #$00
@L12:
    lda     debug_cmd,y
    beq     @out2
    sta     BUFEDT,y
    iny
    bne     @L12
@out2:
    sta     BUFEDT,y

    lda     #<BUFEDT
    ldy     #>BUFEDT
    BRK_KERNEL XEXEC


    lda     $200
    cmp     #ENOMEM
    beq     @print_oom
    rts
@print_oom:
    jsr     exit_interface_confirmed
    print   loader_biname
    lda     #':'
    BRK_KERNEL XWR0
    print   str_oom
    crlf
    rts


basic11_exec_command:
    .byte "basic11 "
    .byte $22
basic11_name_tape_file:
    .res 15

basic10_exec_command:
    .asciiz "basic10"
ftdos_exec_command:
    .asciiz "ftdos"
loader_biname:
    .asciiz "Loader"

debug_cmd:
    .asciiz "lsmem"

.endproc


.proc _debug_lsmem
    ldy     #$00
@L12:
    lda     debug_cmd,y
    beq     @out2
    sta     BUFEDT,y
    iny
    bne     @L12
@out2:
    sta     BUFEDT,y

    lda     #<BUFEDT
    ldy     #>BUFEDT
    BRK_KERNEL XEXEC
    rts
debug_cmd:
    .asciiz "lsmem"
.endproc

