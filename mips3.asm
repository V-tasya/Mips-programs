.data
header:              .asciiz "Please, enter the number of instructions that you want to analyze. \nThis number should be from 1 to 5 \n"
enteredNumber:       .asciiz "Your entered number is "
incorrectNumber:     .asciiz "Your entered number was incorrect, try one more time\n"
newLine:             .asciiz "\n"
executableFunctions: .asciiz "You can enter one of these functions: \n1) ADD $r1, $r2, $r3 \n2) ADDI $r1, $r2, value \n3) J label \n4) NOOP \n5) MULT $s, $t \n6) JR $r1 \n7) JAL label \nPlease, enter without parameters, just command\n"
correctMessage:      .asciiz "Your function is correct\n"
savedMessage:        .asciiz "Your function was completely saved in the stack\n"
enteredFunction:     .asciiz "Your entered function is "
wrongFunction:       .asciiz "You entered wrong function, please try one more time \n"
enteredFunctions:    .asciiz "Your entered functions in reverse order: \n"
ADD:                 .asciiz "ADD"
ADDI:                .asciiz "ADDI"
J_LABEL:             .asciiz "J"
NOOP:                .asciiz "NOOP"
MULT:                .asciiz "MULT"
JR:                  .asciiz "JR"
JAL_LABEL:           .asciiz "JAL"
userInput:           .space 25
functionsArray:      .space 28 
stack_top:           .word  0x7FFFEFFC

messageFunctionsNumber: .asciiz "The space of memory used is "

.text
.globl main

main:
    # Initialize stack pointer to a high address in memory
    # lw $t0, stack_top
    # move $sp, $t0

    # printing the header
    li $v0, 4
    la $a0, header
    syscall

    # waiting for user's input
    li $v0, 5 # the number will be stored in v0
    syscall

    move $s0, $v0 # now the entered value is in s0
    # checking if number is in the range from 1 to 5
    blt $s0, 1, wrongNumber
    bgt $s0, 5, wrongNumber

    li $v0, 4
    la $a0, enteredNumber
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, newLine
    syscall

functions:
    blt $s0, 1, result
    
functions_body:
    li $v0, 4
    la $a0, executableFunctions
    syscall

    li $v0, 8
    la $a0, userInput
    li $a1, 25
    syscall

    la $s1, userInput

    li $v0, 4
    la $a0, enteredFunction
    syscall

    li $v0, 4
    la $a0, userInput
    syscall

    # element pointers
    la $t0, ADDI
    la $t1, ADD
    la $t2, NOOP
    la $t3, MULT
    la $t4, JR
    la $t5, JAL_LABEL
    la $t6, J_LABEL

    # writing pointers in an array
    la $s2, functionsArray
    sw $t0, 0($s2) 
    sw $t1, 4($s2) 
    sw $t2, 8($s2) 
    sw $t3, 12($s2)
    sw $t4, 16($s2) 
    sw $t5, 20($s2)
    sw $t6, 24($s2) 
    # Compare entered function with stored functions
    li $t7, 0 # Index for function array
    li $t8, 7 # Total number of functions

compare_loop:
    beq $t7, $t8, unknownFunction  
    lw $t9, 0($s2)  
    la $a0, userInput
    move $a1, $t9
    jal strcmp
    beq $v0, $zero, stack

    addi $s2, $s2, 4
    addi $t7, $t7, 1
    j compare_loop

strcmp:
    lb $t0, 0($a0)
    lb $t1, 0($a1)
    beq $t0, $zero, strcmp_end
    beq $t1, $zero, strcmp_end
    bne $t0, $t1, strcmp_not_equal
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j strcmp

strcmp_not_equal:
    li $v0, 1
    jr $ra

strcmp_end:
    li $v0, 0
    jr $ra

stack:
    # displaying correct message
    li $v0, 4
    la $a0, correctMessage
    syscall

    # saving function to the stack
    sub $sp, $sp, 4 # moving the stack pointer
    sw  $t9, 0($sp) # saving the correct function on the stack

    # displaying saved function
    li $v0, 4
    la $a0, savedMessage
    syscall

   # li $v0, 1          # Print function value
   # lw $a0, 0($sp)
   # syscall
   
    sub $s0, $s0, 1

    j functions
    
result:
    li $v0, 4
    la $a0, enteredFunctions
    syscall

    lw $t0, stack_top # Load the original top of stack to compare
    
    # printing the amount of functions
		sub $s6, $t0, $sp
		# div $s6, $s6, 4
		li $v0, 4
		la $a0, messageFunctionsNumber
		syscall 
		li $v0, 1
		move $a0, $s6
		syscall
		li $v0, 11
		li $a0, '\n'
		syscall

print_loop:
		# li $v0, 1
		# move $a0, $sp
		# syscall

    beq $sp, $t0, end 
    lw $a0, 0($sp)     # loading the address of the instruction from the stack

    # Print the function value loaded from the stack
    li $v0, 4
    # move $a0, $t9
    syscall

    addi $sp, $sp, 4   # moving the stack pointer back up

    # Print newline for clarity
    li $v0, 4
    la $a0, newLine
    syscall

    j print_loop

wrongNumber:
    li $v0, 4
    la $a0, incorrectNumber
    syscall
    j main

unknownFunction:
    li $v0, 4
    la $a0, wrongFunction
    syscall
    j functions_body

end:
    li $v0, 10
    syscall
