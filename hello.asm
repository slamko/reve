
section .data
    text db "Hello, World!", 0
    exec_p db "/bin/suko", 0
    argv0 db "/bin/suko", 0
    argv dq argv0, text, 0x0

    endln db 10
    env0 db "PATH=/bin", 0
    env dq env0, 0x0

section .bss
    stdata resb 4096
   
section .text
    global _start

    
_start:

_read:  
    mov rax, 0
    mov rdi, 0
    mov rsi, stdata
    mov rdx, 4096
    syscall

    mov rbx, stdata
    dec rbx 
_len:
    inc rbx
    mov cl, [rbx]
    cmp cl, 10
    jne _len 
    
    mov rax, 1
    mov rdi, 1
    mov rdx, 1

_rev:
    dec rbx
    mov rsi, rbx
    syscall
    cmp rbx, stdata
    jne _rev

    
    mov rsi, endln
    syscall
    
    jmp _read
