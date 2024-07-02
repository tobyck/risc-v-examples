.section .rodata
prompt:    .string "Enter a positive integer: "
response:  .string "Double your number is: "
error_msg: .string "Invalid input :(\n"
newline:   .string "\n"

.section .bss
buffer:     .space 11 # max 10 digits + newline

.section .text
.set buffer_len, 11
.global _start
_start:
	# print the prompt
	la  a0, prompt
	li  a1, 26
	jal ra, print

	# read input into buffer
	li a0, 0
	la a1, buffer
	li a2, buffer_len
	li a7, 63
	ecall

	mv a1, a0           # a0 contains the number of bytes read after the 
	                    # read syscall but str_to_int expects it in a1

	addi a1, a1, -1     # decrement to remove the newline
	la   a0, buffer     # load the buffer to convert to an int into a0

	jal  ra, str_to_int # parse as int and load it into a0
	slli a0, a0, 1      # double it by left bit shifting by 1

	# other args for int_to_str
	la  a1, buffer
	li  a2, buffer_len

	jal ra, int_to_str  # convert int back to str
	mv  t0, a0          # temporarily store it t0

	# print response message
	la  a0, response
	li  a1, 24
	jal ra, print

	# restore stringified int from t0 and print it
	mv  a0, t0
	li  a1, buffer_len
	jal ra, print

	# print a trailing newline
	la  a0, newline
	li  a1, 2
	jal ra, print

	j exit

# takes a buffer in a0 and number of bytes to write in a1
print:
	# move args to where they need to be for the syscall
	mv a2, a1
	mv a1, a0

	# write to stdout
	li a0, 1
	li a7, 64
	ecall

	ret

# Args:
#   a0 = buffer
#   a1 = number of bytes in that buffer
#
# Vars:
#   t0 = return value
#   t1 = number of bytes left to read in the buffer
#   t2 = address of current byte to read
#   t3 = power of 10 to multiply current digit by
#   t4 = current digit
#
# Return value: an int in a0
str_to_int:
	xor  t0, t0, t0               # zero out t0 (for the int to return)
	mv   t1, a1                   # store number of bytes left to read in t1
	mv   t2, a0                   # t2 now points to the start of the buffer
	add  t2, t2, t1               # add the length of the buffer so it points to the end
	li   t3, 1                    # this will be multiplied by 10 for each digit
str_to_int_loop:
	beq  t1, zero, str_to_int_end # finish loop if no more bytes to read
	addi t2, t2, -1               # decrement address of current char
	lbu  t4, (t2)                 # load current char into t4

	# error if non-digit
	li   t5, '0'
	li   t6, '9'
	blt  t4, t5, error
	bgt  t4, t6, error

	addi t4, t4, -'0'             # subtract char code of '0' to get digit
	mul  t4, t4, t3               # multiply digit by the current power of ten
	add  t0, t0, t4               # add that to the return value

	li   t5, 10
	mul  t3, t3, t5               # t3 *= 10 for the next digit

	addi t1, t1, -1               # decrement number of bytes left to read
	j    str_to_int_loop
str_to_int_end:
	mv   a0, t0
	ret

# Args:
#   a0 = the int to convert to a string
#   a1 = the buffer to write to
#   a2 = the length of the buffer
#
# Vars:
#   t0   starts as a0 then is repeatedly divided by 10
#   t1 = the current address write to in the buffer
#   t2 = the value 10
#   t3 = the remainder of the division (i.e. current digit as an int)
# 
# Return value: address of the stringified int in a0
int_to_str:
	mv   t0, a0                   # number which will keep being divided by 10
	mv   t1, a1                   # t1 now holds the address of the buffer
	add  t1, t1, a2               # and now it points to the end of the buffer
	li   t2, 10                   # constant

	addi t1, t1, -1
	sb   zero, (t1)               # put a null byte at the end

	beq  a0, zero, zero_to_str    # if the number is zero return early with '0'
int_to_str_loop:
	beq  t0, zero, int_to_str_end # finish loop if no more digits to extract
	addi t1, t1, -1               # decrement address to write char to

	rem  t3, t0, t2
	addi t3, t3, '0'              # add ascii code of '0' to get correct char
	sb   t3, (t1)                 # store digit in buffer
	div  t0, t0, t2
	
	j    int_to_str_loop
int_to_str_end:
	mv   a0, t1                   # return the address in the buffer of the first digit
	ret
zero_to_str:
	addi t1, t1, -1               # move address to write to back one
	li   t3, '0'
	sb   t3, (t1)                 # write a '0' in that position
	j    int_to_str_end

# print error message and exit
error:
	la   a0, error_msg
	li   a1, 17
	jal  ra, print
	j    exit

# exit with status code 0
exit:
	li a0, 0
	li a7, 93
	ecall
