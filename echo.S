.section .rodata
prompt:   .string "Enter something: "
response: .string "You said: "

.section .bss
buffer: .space 100

.section .text
.global _start
_start:
	# print prompt
	la a0, prompt # load address of message
	li a1, 17     # length of message
	jal ra, print # jump to subroutine

	li a0, 1      # file descriptor for read
	la a1, buffer # load address of buffer to read to
	li a2, 100    # max number of bytes to read
	li a7, 63     # system call number for read
	ecall

	# print response message
	la a0, response
	li a1, 10
	jal ra, print

	# print what the user inputted
	la a0, buffer
	li a1, 100
	jal ra, print

	# exit with status code 0
	li a0, 0
	li a7, 93
	ecall

print:
	mv a2, a1
	mv a1, a0
	li a0, 1
	li a7, 64
	ecall
	ret
