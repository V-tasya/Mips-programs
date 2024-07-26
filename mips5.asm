.data
header:                .asciiz    "This is a game XOX. \nThe starting board: \n1 2 3 \n4 5 6 \n7 8 9 \nPlease enter your sign (x or o): \n"
usersChoice:           .asciiz    "Now you play for "
usersInput:            .asciiz    "You entered "
numberOfRounds:        .asciiz    "Please, enter how many rounds do you want to play (1, 2, 3, 4 or 5): \n"
uncurMess:             .asciiz    "Your input was wrong, try one more time \n"
yourMove:              .asciiz    "Now it's your turn to move, please enter the number of the field where you want to put your sign: \n"
player_score_msg:      .asciiz    "Player wins: "
computer_score_msg:    .asciiz    "Computer wins: "
draw_score_msg:        .asciiz    "Draws: "
newline:               .asciiz    "\n"
start_board:           .asciiz    "123456789"  # Initial board setup
board:                 .asciiz    "123456789"  
prompt:                .asciiz    "Wybierz pole (1-9): "
error:                 .asciiz    "Uncurrect choise, try one more time\n"
win_msg:               .asciiz    "You win\n"
lose_msg:              .asciiz    "You lose\n"
draw_msg:              .asciiz    "Draw\n"
nl:                    .asciiz    "\n"

.text
main:
    # Printing the header
    li $v0, 4
    la $a0, header
    syscall

    # Getting users input char x or o
    li $v0, 12
    syscall
    move $s0, $v0  
    li $v0, 11
    la $a0, '\n'
    syscall

    # Checking if user's input is correct
    beq $s0, 'x', choose_rounds
    beq $s0, 'o', choose_rounds
    j uncurrectMessage

choose_rounds:
    # Printing the user's choice
    li $v0, 4
    la $a0, usersChoice
    syscall
    move $a0, $s0
    li $v0, 11
    syscall
    
    li $v0, 11
    la $a0, '\n'
    syscall

    # Getting the number of rounds
    li $v0, 4
    la $a0, numberOfRounds
    syscall

    li $v0, 5
    syscall
    move $s1, $v0  # Number of rounds

    # Checking if the number of rounds is correct
    blt $s1, 1, wrongNum
    bgt $s1, 5, wrongNum

    # Initialize scores
    li $t0, 0  # Player score
    li $t1, 0  # Computer score
    li $t2, 0  # Draws

    add $t3, $s1, $zero  # Remaining rounds

game_round:
    # Reset board
    la $a0, board
    la $a1, start_board
    li $t4, 9  
    
reset_loop:
    lb $t5, 0($a1)
    sb $t5, 0($a0) 
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    subi $t4, $t4, 1
    bnez $t4, reset_loop

    beq $s0, 'x', player_starts
    beq $s0, 'o', player_starts
    j print_board

player_starts:
    la $a0, board         
    jal print_board       

game_loop:
    la $a0, prompt        
    li $v0, 4             
    syscall

    li $v0, 5             
    syscall
    sub $t0, $v0, 1       # minus 1 from choise to finde the tab index
    blt $t0, 0, invalid_move
    bgt $t0, 8, invalid_move

    la $t1, board         
    add $t1, $t1, $t0   
    lb $t2, 0($t1)       
    li $t3, '1'           
    add $t3, $t3, $t0    
    bne $t2, $t3, invalid_move

    move $t2, $s0         
    sb $t2, 0($t1)       
    jal print_board       
    jal check_win         
    beq $v0, 1, player_win

    jal computer_move    
    jal print_board       
    jal check_win        
    beq $v0, 1, computer_win

    j game_loop

invalid_move:
    la $a0, error         
    li $v0, 4             
    syscall
    j game_loop

player_win:
    la $a0, win_msg      
    li $v0, 4             
    syscall
    addi $s3, $s3, 1     
    j round_end

computer_win:
    la $a0, lose_msg      
    li $v0, 4             
    syscall
    addi $s2, $s2, 1      
    j round_end

draw:
    la $a0, draw_msg      
    li $v0, 4             
    syscall
    addi $s4, $s4, 1     
    j round_end           

round_end:
    subi $s1, $s1, 1      
    beqz $s1, print_scores
    j game_round

print_scores:
    # Print player score
    li $v0, 4
    la $a0, player_score_msg
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Print computer score
    li $v0, 4
    la $a0, computer_score_msg
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Print draws
    li $v0, 4
    la $a0, draw_score_msg
    syscall
    move $a0, $s4
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    j end

uncurrectMessage:
    li $v0, 4
    la $a0, uncurMess
    syscall
    j main

wrongNum:
    li $v0, 4
    la $a0, uncurMess
    syscall
    j main

end:
    li $v0, 10
    syscall


print_board:
    la $t0, board         
    li $t1, 0             

print_loop:
    lb $a0, 0($t0)        
    li $v0, 11            
    syscall
    addi $t0, $t0, 1      
    addi $t1, $t1, 1      

    li $t2, 3             
    div $t3, $t1, $t2     
    mfhi $t4              
    beqz $t4, new_line    
    li $t5, 9             
    bne $t1, $t5, print_loop
    jr $ra

new_line:
    la $a0, nl           
    li $v0, 4             
    syscall
    li $t5, 9             
    bne $t1, $t5, print_loop
    li $v0, 11
    la $a0, '\n'
    syscall
    jr $ra

check_win:
    la $t0, board
    lb $t1, 0($t0)
    lb $t2, 1($t0)
    lb $t3, 2($t0)
    beq $t1, $t2, row1
    b check_row2

row1:
    beq $t2, $t3, win
    b check_row2

check_row2:
    lb $t1, 3($t0)
    lb $t2, 4($t0)
    lb $t3, 5($t0)
    beq $t1, $t2, row2
    b check_row3

row2:
    beq $t2, $t3, win
    b check_row3

check_row3:
    lb $t1, 6($t0)
    lb $t2, 7($t0)
    lb $t3, 8($t0)
    beq $t1, $t2, row3
    b check_col1

row3:
    beq $t2, $t3, win
    b check_col1

check_col1:
    lb $t1, 0($t0)
    lb $t2, 3($t0)
    lb $t3, 6($t0)
    beq $t1, $t2, col1
    b check_col2

col1:
    beq $t2, $t3, win
    b check_col2

check_col2:
    lb $t1, 1($t0)
    lb $t2, 4($t0)
    lb $t3, 7($t0)
    beq $t1, $t2, col2
    b check_col3

col2:
    beq $t2, $t3, win
    b check_col3

check_col3:
    lb $t1, 2($t0)
    lb $t2, 5($t0)
    lb $t3, 8($t0)
    beq $t1, $t2, col3
    b check_diag1

col3:
    beq $t2, $t3, win
    b check_diag1

check_diag1:
    lb $t1, 0($t0)
    lb $t2, 4($t0)
    lb $t3, 8($t0)
    beq $t1, $t2, diag1
    b check_diag2

diag1:
    beq $t2, $t3, win
    b check_diag2

check_diag2:
    lb $t1, 2($t0)
    lb $t2, 4($t0)
    lb $t3, 6($t0)
    beq $t1, $t2, diag2
    b check_draw

diag2:
    beq $t2, $t3, win
    b check_draw

check_draw:
    li $v0, 0
    jr $ra

win:
    li $v0, 1
    jr $ra

computer_move:
    la $t0, board     
    li $t1, '1'       
    
    
find_move:
    lb $t2, 0($t0)  
    beq $t2, $t1, move_found  
    addi $t0, $t0, 1   
    addi $t1, $t1, 1  
    
    li $t3, '9'        
    bgt $t1, $t3, declare_draw  

    b find_move        

move_found:
    beq $s0, 'x', move_found1
    beq $s0, 'o', move_found2

move_found1:
    li $t2, 'O'
    sb $t2, 0($t0)
    jr $ra

move_found2:
    li $t2, 'x'
    sb $t2, 0($t0)
    jr $ra

declare_draw:
    jal draw
    jr $ra
