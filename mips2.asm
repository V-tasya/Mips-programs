.data
	prompt_message:       .asciiz "Please, enter the text: "
	cleaned_message:      .asciiz "This is cleaned input: "
	mode_message:         .asciiz "Please, choose mode: (E - encode, D - decode): "
	mode_unknown:         .asciiz "Unknown mode was provided. Please, try again: "
	mode_encode:          .asciiz "Provided mode: encode"
	mode_decode:          .asciiz "Provided mode: decode"
	continue_message:     .asciiz "Do you want to continue? (Y - yes, N - no): "
	key_message_start:    .asciiz "Please, enter the "
	key_message_end:      .asciiz " digit: "
	show_key_message:     .asciiz "This is your key (for decode it's reversed): "
	result_message:       .asciiz "The result is: "
	repeat_message:       .asciiz "Repeat (Y -- yes, everything else -- no)?"
	input:                .space 50
	cleaned:              .space 50
	key:                  .space 8
	result:               .space 50

.macro exit
	li $v0, 10
	syscall
.end_macro

.macro print_formatted(%start, %middle, %end)
	li $v0, 4
	la $a0, %start
	syscall
	li $v0, 1
	move $a0, %middle
	syscall
	li $v0, 4
	la $a0, %end
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
.end_macro

.macro print_integer(%value)
	li $v0, 1
	move $a0, %value
	syscall
.end_macro

.macro print_string(%message)
	li $v0, 4
	la $a0, %message
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
.end_macro

.macro get_string(%address, %space)
	li $v0, 8
	la $a0, %address
	li $a1, %space 
	syscall
.end_macro

.macro get_character
	li $v0, 12
	syscall
.end_macro

.macro get_integer
	li $v0, 5
	syscall
.end_macro

.macro endl
	li $v0, 11
	li $a0, '\n'
	syscall
.end_macro

.text
main:
  li $v0, 11
  la $a0, '\n'
  syscall
	# getting input
	print_string(prompt_message)
	get_string(input, 50)
	# cleaning input
	jal clean_input
	print_string(cleaned_message)
	print_string(cleaned)
	# getting mode to $s0
	print_string(mode_message)
	jal get_mode
	# getting the key
	jal get_key
	jal print_key
	# translating
	jal init_result
	jal apply_key
	# printing the result
	print_string(result_message)
	print_string(result)
	# requesting for repeat
	print_string(repeat_message)
	get_character
	beq $v0, 'Y', main
	exit
	
clean_input:
	la $t0, input
	la $t1, cleaned
	loop:
	lb $t2, ($t0)
	beq $t2, '\0', loop_exit
	blt $t2, 'A', loop_tail
	bgt $t2, 'Z', loop_tail
	sb $t2, ($t1)
	addi $t1, $t1, 1
	loop_tail:
	addi $t0, $t0, 1
	j loop
	loop_exit:
	sb $zero, ($t1)
	la $t1, result
	sb $zero, ($t1)
	jr $ra

get_mode:
	get_character
	move $s0, $v0
	endl
	beq $s0, 'E', case_encode
	beq $s0, 'D', case_decode
	j case_unknown
	case_encode:
		print_string(mode_encode)
		jr $ra
	case_decode:
		print_string(mode_decode)
		jr $ra
	case_unknown:
		print_string(mode_unknown)
		j get_mode

get_key:
	la $t0, key
	li $t1, 0
	get_key_loop:
		print_formatted(key_message_start, $t1, key_message_end)
		get_integer
		move $t2, $v0
		beq $s0, 'D', case_decode_
			# case encode:
			add $t3, $t0, $t1
			sb $t2, ($t3)
			j get_key_loop_end
		case_decode_:
			add $t3, $t0, $t2
			sb $t1, ($t3)
	get_key_loop_end:
		add $t1, $t1, 1
		blt $t1, 8, get_key_loop
	jr $ra

print_key:
	print_string(show_key_message)
	li $t0, 0
	la $t1, key
	print_key_loop:
		add $t2, $t0, $t1
		lb $t3, ($t2)
		print_integer($t3)
		add $t0, $t0, 1
		blt $t0, 8, print_key_loop
	endl
	jr $ra

init_result:
	li $t0, 0
	la $t1, result
	init_result_loop:
	add $t2, $t0, $t1
	li $t3, ' '
	sb $t3, ($t2)
	add $t0, $t0, 1
	blt $t0, 49, init_result_loop
	jr $ra

apply_key:
	la $t0, 0 # position in the source string
	apply_key_loop:
		# loading character from cleaned on the $t0 position
		la $t1, cleaned
		add $t1, $t1, $t0
		lb $t1, ($t1) 
		# if it's null terminator, exit
		beq $t1, '\0', apply_key_end
		
		# loading value from key from the position $t0/8
		rem $t2, $t0, 8 
		la $t3, key
		add $t2, $t2, $t3
		lb $t2, ($t2)
		
		# loading result address, counting the new position in the result, and writing it in the cleaned
		la $t3, result
		add $t3, $t3, $t0
		
		# storing
		add $t3, $t3, $t2
		rem $t4, $t0, 8
		sub $t3, $t3, $t4
		sb $t1, ($t3)
		
		# incremeting
		add $t0, $t0, 1
		
		j apply_key_loop
		apply_key_end:
			jr $ra

exit
