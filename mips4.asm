.data
	prompt_message: .asciiz "Please, choose the function: (1-3)"
	func_f: .asciiz "1) f(x, y) = 1 if x = y or y = 0, otherwise f(x-1, y) + f(x-1,y-1) for x > y"
	func_g: .asciiz "2) g(x, y) = 1 if x = y or y = 0, otherwise 2*g(x-1,y)+2*g(x-1,y-1) for x > y"
	func_h: .asciiz "3) h(x, y) = 2 if x = y or y = 0, otherwise 2*h(x-1,y)+h(x-1,y-1) for x > y"
	wrong_input: .asciiz "Wrong input. Expected 1, 2 or 3. Try again"
	prompt_x: .asciiz "Please, enter float x: "
	prompt_y: .asciiz "Please, enter float y: "
	undefined_message: .asciiz "Function is undefined"
	result_message: .asciiz "The result is: "
	float_zero: .float 0.0
	float_one: .float 1.0
	float_two: .float 2.0
.text

.macro get_int
	li $v0, 5
	syscall
.end_macro

.macro get_float
	li $v0, 6
	syscall
.end_macro

.macro print_string(%str)
	li $v0, 4
	la $a0, %str
	syscall
	li $v0, 11
	la $a0, '\n'
	syscall
.end_macro

.macro print_float(%float)
	li $v0, 2
	mov.s $f12, %float
	syscall
.end_macro

.macro exit
	li $v0, 10
	syscall
.end_macro

.macro stack_float_push(%reg)
	addi $sp, $sp, -4
	s.s %reg, ($sp)
.end_macro

.macro stack_push(%reg)
	addi $sp, $sp, -4
	sw %reg, ($sp)
.end_macro

.macro unwind_and_return(%stack_size)
	lw $ra, ($sp)
	addi $sp, $sp, %stack_size
	jr $ra
.end_macro

main:

function_choose:
	print_string (prompt_message)
	print_string (func_f)
	print_string (func_g)
	print_string (func_h)
	
	get_int
	move $s0, $v0
	beq $s0, 1, function_start
	beq $s0, 2, function_start
	beq $s0, 3, function_start
	print_string (wrong_input)
	j function_choose

function_start:
	# getting input
	print_string (prompt_x)
	get_float
	mov.s $f12, $f0
	print_string (prompt_y)
	get_float
	mov.s $f14, $f0
	# checking whether x < y
	c.lt.s $f12, $f14
	bc1t function_undefined
	jal function_body
	print_string (result_message)
	print_float ($f0)
	exit
	
function_undefined:
	print_string (undefined_message)
	exit	

function_body:
	# checking for base case
	lwc1 $f2, float_zero
	c.eq.s $f14, $f2
	bc1t base_case
	c.eq.s $f14, $f12
	bc1t base_case
	
	# putting on the stack
	stack_float_push ($f12) # place for x
	stack_float_push ($f14) # place for y
	lwc1 $f2, float_zero
	stack_float_push ($f2) # place for f(x-1, y)
	stack_float_push ($f2) # place for f(x-1, y-1)
	stack_push ($ra) # saving return address
	
	# 8($sp) = f(x-1, y)
	lwc1 $f2, float_one
	sub.s $f12, $f12, $f2
	jal function_body
	s.s $f0, 8($sp)
	
	# 4($sp) = f(x-1, y-1)
	lwc1 $f2, float_one
	lwc1 $f12, 16($sp)
	sub.s $f12, $f12, $f2
	lwc1 $f14, 12($sp)
	sub.s $f14, $f14, $f2
	jal function_body
	s.s $f0, 4($sp)
	
	beq $s0, 1, skip_first_mult
  lwc1 $f2, float_two
	lwc1 $f3, 8($sp)
	mul.s $f3, $f3, $f2
	s.s $f3, 8($sp)
	
skip_first_mult:
	
  beq $s0, 1, skip_second_mult
	beq $s0, 3, skip_second_mult
	lwc1 $f2, float_two
	lwc1 $f3, 4($sp)
	mul.s $f3, $f3, $f2
	s.s $f3, 4($sp)
	
skip_second_mult:
	
	lwc1 $f2, 4($sp)
	lwc1 $f3, 8($sp)
	add.s $f0, $f2, $f3 #f(x-1, y) + f(x-1, y-1)
	
	unwind_and_return (20)
	 
base_case:
		
  beq $s0, 3, return_2
	lwc1 $f0, float_one
	jr $ra
	return_2:
	lwc1 $f0, float_two
	jr $ra

exit
