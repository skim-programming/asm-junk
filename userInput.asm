section .data
  prompt: db 'Please enter text(shorter than 65 characters): ', 10
  promptLen: equ $-prompt
  app: db 'You entered: '
  appLen: equ $-app
	
section .bss
  buffer: resb 64
  out: resb 72

section .text
	global _start
	

_start:
  mov edi, prompt
  mov esi, promptLen
  call _print
  mov edi, buffer
  mov esi, 64
  call _in
	lea rdi, out
	mov rsi, app
	mov rdx, appLen
	mov rcx, buffer
	mov r8, 64
	call _buffercpy
	mov byte [out + 71], 10
	mov edi, out
	mov esi, 72
	call _print
	jmp _exit
	
_buffercpy: 
  ; params: rdi (writeBuffer), rsi (b1), rdx (b1len), rcx (b2), r8 (b2len)
  mov r9, 0   ; index of writeBuffer
  mov r10, 0  ; index for b1 loop
  call _b1loop
  call _b2loop
  ret

_b1loop:
  cmp r10, rdx        ; compare index with b1 length
  jge _b2setup        ; if done with b1, go to b2
  mov al, [rsi+r10]   ; load byte from b1 into 8-bit register
  mov [rdi+r9], al    ; store byte into writeBuffer
  inc r9
  inc r10
  jmp _b1loop

_b2setup:
  mov r11, 0          ; index for b2 loop

_b2loop:
  cmp r11, r8         ; compare index with b2 length
  jge _ret            ; if done, exit
  mov al, [rcx+r11]   ; load byte from b2 (buffer)
  mov [rdi+r9], al    ; store byte into writeBuffer
  inc r9
  inc r11
  jmp _b2loop

_ret:
  ret
  
_print:
  mov eax, 4 ; syscall number for sys_write
  mov ebx, 1 ; file descriptor for stdout
  mov ecx, edi ; buffer
  mov edx, esi ; buffer size
  int 80h ; call kernel
  ret
  
_in:
  mov eax, 3 ; syscall number for sys_read
  mov ebx, 0 ; file descriptor for stdin
  mov ecx, edi ; buffer
  mov edx, esi ; buffer size
  int 80h
  ret
  
_exit:
  mov eax, 1
  mov ebx, 80h
  int 80h
