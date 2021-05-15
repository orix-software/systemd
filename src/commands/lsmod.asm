.proc _lsmod
    print str_lsmod,NOSAVE
  
    rts
str_lsmod:
    .asciiz "lsmod"    
.endproc
