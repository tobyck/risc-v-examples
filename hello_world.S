.section .text
hello: .asciz "Hello, World!\n"

.section .text
.global _start
_start:
	li a0, 1     # file descriptor for stdout
	la a1, hello # load message
	li a2, 14    # length of the string
	li a7, 64    # syscall number for write
	ecall

	li a0, 0  # exit status zero
	li a7, 93 # syscall number for exit
	ecall
