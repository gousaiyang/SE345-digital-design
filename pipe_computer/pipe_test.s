start:     lw $30, 0($0)         # load sevenseg code for '-' from datamem
           lw $29, 4($0)         # load sevenseg code for 'P' from datamem
           lw $28, 8($0)         # load sevenseg code for 'A' from datamem
           lw $27, 12($0)        # load sevenseg code for 'S' from datamem
           lw $26, 16($0)        # load sevenseg code for 'F' from datamem
           lw $25, 20($0)        # load sevenseg code for 'I' from datamem
           lw $24, 24($0)        # load sevenseg code for 'L' from datamem
           sw $0, 36($0)         # datamem[0x24] <- 0
           j main                # enter test program
           add $0, $0, $0        # nop padding
test_fail: sw $30, 65392($0)     # display '-' at hex5
           sw $26, 65376($0)     # display 'F' at hex4
           sw $28, 65360($0)     # display 'A' at hex3
           sw $25, 65344($0)     # display 'I' at hex2
           sw $24, 65328($0)     # display 'L' at hex1
           sw $30, 65312($0)     # display '-' at hex0
           j end                 # halt the program
main:      lui $1, 0             # $1 <- 0
           j s1                  # test delay slot of 'j'
           addi $1, $0, 1        # $1 <- 1 should be executed before jumping
           addi $1, $0, 2        # should not come here
s1:        addi $2, $0, 1        # $2 <- 1
           bne $1, $2, test_fail # check $1 == 1
           add $0, $0, $0        # nop padding
           bne $0, $1, s2        # test delay slot of 'bne'
           and $1, $1, $0        # $1 <- 0 should be executed before jumping
s2:        bne $0, $1, test_fail # check $1 == 0
           add $0, $0, $0        # nop padding
           beq $0, $1, s3        # test delay slot of 'beq'
           ori $1, $1, 1         # $1 <- 1 should be executed before jumping
s3:        beq $0, $1, test_fail # check $1 != 0
           add $0, $0, $0        # nop padding
           jal s4                # test delay slot of 'jal'
           xor $1, $1, $1        # $1 <- 0 should be executed before call
           j s5                  # should return here (PC + 8) and goto s5
           add $0, $0, $0        # nop padding
s4:        bne $0, $1, test_fail # check $1 == 0
           add $0, $0, $0        # nop padding
           jr $ra                # test delay slot of 'jr'
           xori $1, $0, 2        # $1 <- 2 should be executed before return
s5:        addi $2, $2, 1        # $2 <- 2
           bne $1, $2, test_fail # check $1 == 2
           add $1, $1, $1        # $1 <- 4
           add $1, $1, $1        # test forwarding, $1 should be 8
           add $1, $1, $1        # test forwarding, $1 should be 16
           add $1, $1, $1        # test forwarding, $1 should be 32
           sll $2, $2, 4         # $2 <- 32
           bne $1, $2, test_fail # check $1 == 32
           srl $2, $2, 2         # $2 <- 8
           add $0, $0, $0        # nop padding
           add $1, $2, $2        # test forwarding, $1 should be 16
           addi $3, $0, 1        # $3 <- 1
           sll $3, $3, 4         # $3 <- 16
           bne $1, $3, test_fail # check $1 == 16
           lw $1, 28($0)         # $1 <- 204 (from datamem)
           addi $2, $0, 0xcc     # $2 <- 0xcc (204)
           bne $1, $2, test_fail # check $1 == 204 (test forwarding)
           add $0, $1, $1        # should cause no effect
           add $1, $0, $0        # $1 should be 0
           bne $0, $1, test_fail # check $1 == 0 (test forbid forwarding $0)
           addi $1, $0, 1        # $1 <- 1
           add $0, $1, $1        # should cause no effect
           add $1, $1, $1        # $1 <- 2
           add $1, $0, $0        # $1 should be 0
           bne $0, $1, test_fail # check $1 == 0 (test forbid forwarding $0)
           lw $0, 28($0)         # should cause no effect
           add $1, $1, $1        # $1 <- 0
           add $1, $0, $0        # $1 should be 0
           bne $0, $1, test_fail # check $1 == 0 (test forbid forwarding $0)
           addi $1, $0, 1        # $1 <- 1
           sub $1, $1, $1        # $1 <- 0
           bne $0, $1, test_fail # check $1 == 0
           sll $2, $2, 24        # $2 <- 0xcc000000
           srl $3, $2, 31        # $3 <- 0x00000001 (test zero extension)
           sra $2, $2, 31        # $2 <- 0xffffffff (test sign extension)
           lw $1, 32($0)         # $1 <- 0xffffffff (from datamem)
           bne $1, $2, test_fail # check $1 == -1, test load/use hazard
           add $1, $1, $3        # $1 <- 0
           bne $0, $1, test_fail # check $1 == 0
           addi $1, $0, 0xffff   # $1 <- 0xffffffff (test sign extension)
           bne $1, $2, test_fail # check $1 == -1
           xori $1, $1, 0xffff   # $1 <- 0xffff0000 (test zero extension)
           beq $0, $1, test_fail # check $1 != 0
           andi $1, $1, 0        # $1 <- 0
           bne $0, $1, test_fail # check $1 == 0
           or $1, $1, $2         # $1 <- 0xffffffff
           beq $0, $1, test_fail # check $1 != 0
           lui $1, 1             # $1 <- 0x00010000
           sw $1, 36($0)         # datamem[0x24] <- 0x00010000
           lw $2, 36($0)         # $2 <- datamem[0x24] (0x00010000)
           bne $1, $2, test_fail # check $1 == $2 (test load/store)
           addi $3, $0, 1        # $3 <- 1
           sll $3, $3, 16        # $3 <- 0x00010000
           bne $1, $3, test_fail # check $1 == 0x00010000 (test lui)
           sw $30, 65392($0)     # display '-' at hex5
           sw $29, 65376($0)     # display 'P' at hex4
           sw $28, 65360($0)     # display 'A' at hex3
           sw $27, 65344($0)     # display 'S' at hex2
           sw $27, 65328($0)     # display 'S' at hex1
           sw $30, 65312($0)     # display '-' at hex0
end:       j end                 # halt the program
           add $0, $0, $0        # nop padding
