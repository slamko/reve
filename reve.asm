BUF_LEN equ 4096
    
section .data
    endln db 10

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    cbbuf resb 8
   
section .text
    global _start
    
_start:

_read:  
    mov rax, 0
    mov rdi, 0
    mov rsi, stdata
    mov rdx, BUF_LEN
    syscall

    mov rbx, stdata
    dec rbx 
_len:
    inc rbx
    mov cl, [rbx]
    cmp cl, 10
    je _cleanbuf
    mov rdx, BUF_LEN
    add rdx, stdata
    cmp rbx, rdx
    jl _len
    
_cleanbuf:
    mov rdx, rbx
    sub rdx, stdata
    cmp rdx, BUF_LEN
    jl _init_rev

_cbloop:
    mov rax, 0
    mov rdi, 0
    mov rsi, cbbuf
    mov rdx, 1
    syscall

    cmp byte [cbbuf], 10
    jne _cbloop

_init_rev:  
    mov rax, 1
    mov rdi, 1
    mov rdx, rbx
    sub rdx, stdata
    mov rcx, revbuf
    dec rcx

_rev:
    dec rbx
    inc rcx

    mov rsi, [rbx]
    mov [rcx], rsi
    cmp rbx, stdata
    jge _rev

    inc rcx
    mov byte [rcx], 0
    mov rsi, revbuf
    syscall

    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    mov rsi, endln
    syscall
    
    jmp _read
