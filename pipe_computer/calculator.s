start:       j main_loop              # enter main loop, delay slot underneath
             lui $7, 0                # $7 stores op (0->add (default), 1->sub, 2->xor)
sevenseg:    sll $30, $30, 2          # calculate sevenseg table item addr to load
             jr $ra                   # return, delay slot underneath
             lw $29, 0($30)           # load sevenseg code of arg($30) from data memory to $29
split:       add $29, $0, $0          # $29 stores tens digit
split_loop:  addi $30, $30, -10       # decrement arg($30) by 10
             sra $28, $30, 31         # extend sign digit of the result
             bne $28, $0, split_done  # if $30 has become negative, goto split_done
             add $0, $0, $0           # nop padding
             j split_loop             # continue loop, delay slot underneath
             addi $29, $29, 1         # increment tens digit
split_done:  jr $ra                   # return, delay slot underneath
             addi $28, $30, 10        # get units digit and store to $28
show:        add $20, $31, $0         # store return address to $20
             sll $26, $29, 5          # $26 = 32 * $29(arg2, pos)
             jal split                # call split (passing $30, arg1, value), delay slot underneath
             addi $26, $26, 0xff20    # calculate sevenseg pair base addr and store to $26
             jal sevenseg             # call split (passing $30), delay slot underneath
             add $30, $29, $0         # move $29(returned tens digit) to $30
             sw $29, 16($26)          # show sevenseg tens digit
             jal sevenseg             # call split (passing $30), delay slot underneath
             add $30, $28, $0         # move $28(returned units digit) to $30
             sw $29, 0($26)           # show sevenseg units digit
             add $31, $20, $0         # restore return address
             jr $ra                   # return
get_op:      lw $5, 65296($0)         # load state of keys to $5
             addi $6, $0, -1          # store 32'bffffffff to $6
             xor $5, $5, $6           # $5 = ~$5
             andi $6, $5, 0x8         # get state of key3
             bne $6, $0, add_op       # if key3 is pressed, change op to add
             add $0, $0, $0           # nop padding
             andi $6, $5, 0x4         # get state of key2
             bne $6, $0, sub_op       # if key2 is pressed, change op to sub
             add $0, $0, $0           # nop padding
             andi $6, $5, 0x2         # get state of key1
             bne $6, $0, xor_op       # if key1 is pressed, change op to xor
             add $0, $0, $0           # nop padding
             jr $ra                   # no key pressed, no op change, return
add_op:      addi $6, $6, -5          # calculate new opcode
sub_op:      addi $6, $6, -3          # calculate new opcode
xor_op:      jr $ra                   # return, delay slot underneath
             add $7, $6, $0           # calculate new opcode and store to $7
do_op:       bne $7, $0, not_add      # check if op is add
             add $0, $0, $0           # nop padding
             jr $ra                   # return, delay slot underneath
             add $4, $2, $3           # do add
not_add:     addi $8, $7, -1          # check if op is sub
             bne $8, $0, not_sub      # check if op is sub
             sub $4, $2, $3           # do sub
             sra $5, $4, 31           # extend sign digit of the result
             beq $5, $0, sub_done     # result is positive, done
             add $0, $0, $0           # nop padding
             sub $4, $0, $4           # result = -result (get abs of result)
sub_done:    jr $ra                   # return
             add $0, $0, $0           # nop padding
not_sub:     jr $ra                   # return, delay slot underneath
             xor $4, $2, $3           # do xor
main_loop:   lw $1, 65280($0)         # load state of switches to $1
             sw $1, 65408($0)         # store $1 to state of leds
             andi $2, $1, 0x3e0       # calculate value1 and store to $2
             jal get_op               # call get_op, delay slot underneath
             srl $2, $1, 5            # calculate value1 and store to $2
             jal do_op                # call do_op (passing $2 and $3), delay slot underneath
             andi $3, $1, 0x1f        # calculate value2 and store to $3
             add $30, $4, $0          # move $4(result) to $30
             jal show                 # call show (passing $30 and $29), delay slot underneath
             addi $29, $0, 0          # set pos to 0 (right pair)
             add $30, $2, $0          # move $2(value1) to $30
             jal show                 # call show (passing $30 and $29), delay slot underneath
             addi $29, $0, 2          # set pos to 2 (left pair)
             add $30, $3, $0          # move $3(value2) to $30
             jal show                 # call show (passing $30 and $29), delay slot underneath
             addi $29, $0, 1          # set pos to 1 (middle pair)
             j main_loop              # loop forever
             add $0, $0, $0           # nop padding
