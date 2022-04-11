;	Licensed to the Apache Software Foundation (ASF) under one
;	or more contributor license agreements.  See the NOTICE file
;	distributed with this work for additional information
;	regarding copyright ownership.  The ASF licenses this file
;	to you under the Apache License, Version 2.0 (the
;	"License"); you may not use this file except in compliance
;	with the License.  You may obtain a copy of the License at
;	
;	 http://www.apache.org/licenses/LICENSE-2.0
;	
;	Unless required by applicable law or agreed to in writing,
;	software distributed under the License is distributed on an
;	"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
;	KIND, either express or implied.  See the License for the
;	specific language governing permissions and limitations
;	under the License.

SECTION .bss
    buffer resb 1

SECTION .text

	global _start

_start:

loop:
	; Read data from STDIN
	mov		rsi, buffer
	mov		rdi, 1
	call 	read

	; Look for the terminating character
  	cmp		rax, 0x00			; Check if the character is null
	je 		end;				; If '\0' found, print the string

	; Don't touch ASCII symbols with value < 65
	cmp  	byte [buffer], 65
	jl		flip_end

	; Don't touch ASCII symbols with value > 122
	cmp		byte[buffer], 122
	jg		flip_end

	; Don't touch symbols in range [91, 96]
	mov 	ch, byte [buffer]
	sub		ch, 91
	cmp 	ch, 5
	jna		flip_end

	; Trick to flip the case of the symbol
	xor		byte[buffer], 0b00100000

flip_end:
	; Print the updated string to the terminal
	mov		rsi, buffer
	mov		rdi, 1
	call 	print

	; Reset the data after the read
	mov		byte [buffer], 0
	xor		rax, rax

	; Get to the start of the loop
	jmp 	loop

end:
	; Print the ending '\n' character
	mov 	byte [buffer], 10
	mov		rsi, buffer
	mov		rdi, 1
	call 	print

	; Exit the process (Linux 64-bit version)
	mov     rax, 60
	xor     rdi, rdi
	syscall

;
; @brief : Read data from STDIN
;
; @param rsi The buffer where to put the result
; @param rdi Amount of bytes to read
;
read:
	; Prolog of the function
	push	rbp
	mov		rbp, rsp

	; Call the system function to print the data
	mov 	rdx, rdi	; Size of the data
	xor 	rdi, rdi	; File descriptor (stdin = 0)
    mov 	rax, rax	; SYSCALL number for reading from STDIN (0)
    syscall

	; Epilog of the function
	mov		rsp, rbp
	pop		rbp

	ret

;
; @brief : Write data to STDOUT
;
; @param rsi The buffer where the data lies
; @param rdi Amount of bytes to write
;
print:
	; Prolog of the function
	push	rbp
	mov		rbp, rsp

	; Call the system function to write the data to STDOUT
	mov		rdx, rdi 	; Size of the data
	mov		rax, 1		; SYSCALL number for writing to STDOUT (1)
	mov		rdi, 1		; File descriptor (stdout = 1)
	syscall

	; Epilog of the function
	mov		rsp, rbp
	pop		rbp

	ret