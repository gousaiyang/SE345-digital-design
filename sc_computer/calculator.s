start:       j main_loop
sevenseg:    sll $30, $30, 2          # calculate sevenseg table item addr to load
             lw $29, 0($30)           # load sevenseg code of arg($30) from data memory to $29
             jr $ra                   # return
split:       addi $27, $0, -1         # store 32'bffffffff to $27
             add $29, $0, $0          # $29 stores tens digit
split_loop:  addi $30, $30, -10       # decrement arg($30) by 10
             sra $28, $30, 31         # extend sign digit of the result
             beq $28, $27, split_done # if $30 has become negative, goto split_done
             addi $29, $29, 1         # increment tens digit
             j split_loop
split_done:  addi $28, $30, 10        # get units digit and store to $28
             jr $ra                   # return
show:        add $20, $31, $0         # store return address to $20
             sll $26, $29, 5          # $26 = 32 * $29(arg2, pos)
             addi $26, $26, 0xff20    # calculate sevenseg pair base addr and store to $26
             jal split                # call split (passing $30, arg1, value)
             add $30, $29, $0         # move $29(returned tens digit) to $30
             jal sevenseg             # call split (passing $30)
             sw $29, 16($26)          # show sevenseg tens digit
             add $30, $28, $0         # move $28(returned units digit) to $30
             jal sevenseg             # call split (passing $30)
             sw $29, 0($26)           # show sevenseg units digit
             add $31, $20, $0         # restore return address
             jr $ra                   # return
main_loop:   lw $1, 65280($0)         # load state of switches to $1
             sw $1, 65408($0)         # store $1 to state of leds
             andi $2, $1, 0x3e0       # calculate value1 and store to $2
             srl $2, $1, 5            # calculate value1 and store to $2
             andi $3, $1, 0x1f        # calculate value2 and store to $3
             add $4, $2, $3           # calculate sum of value1 and value2
             add $30, $4, $0          # move $4(sum) to $30
             addi $29, $0, 0          # set pos to 0 (right pair)
             jal show                 # call show (passing $30 and $29)
             add $30, $2, $0          # move $2(value1) to $30
             addi $29, $0, 2          # set pos to 2 (left pair)
             jal show                 # call show (passing $30 and $29)
             add $30, $3, $0          # move $3(value2) to $30
             addi $29, $0, 1          # set pos to 1 (middle pair)
             jal show                 # call show (passing $30 and $29)
             j main_loop              # loop forever
