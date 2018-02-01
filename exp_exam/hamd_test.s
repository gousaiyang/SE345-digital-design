start:       j main_loop              # enter main loop
sevenseg:    sll $30, $30, 2          # calculate sevenseg table item addr to load
             jr $ra                   # return, delay slot underneath
             lw $29, 0($30)           # load sevenseg code of arg($30) from data memory to $29
main_loop:   lw $1, 65280($0)         # load state of switches to $1
             andi $1, $1, 0xff        # get SW[7..0]
             addi $2, $0, 0xca        # $2 <= 8'b11001010
             jal sevenseg             # call sevenseg (passing $30), delay slot underneath
             hamd $30, $2, $1         # calculate hamming distance and store to $30
             j main_loop              # loop forever, delay slot underneath
             sw $29, 65312($0)        # show result on HEX0
