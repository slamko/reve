BUF_LEN equ 4096
    
section .data
    endln db 10

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    cbbuf resb 8
   
section .text
    global _start

_sys_write_init:
    mov rax, 1
    mov rdi, 1
    ret

_sys_read_init:
    mov rax, 0
    mov rdi, 0
    ret

_exit:
    mov rax, 60
    mov rdi, 0
    syscall
    ret
    
_start:

_read:  
    call _sys_read_init
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
    call _sys_read_init
    mov rsi, cbbuf
    mov rdx, 1
    syscall

    cmp byte [cbbuf], 10
    jne _cbloop

_init_rev:  
    call _sys_write_init
    mov rdx, rbx
    sub rdx, stdata
    add rdx, 2
    mov rcx, revbuf
    dec rcx

_rev:
    dec rbx
    inc rcx

    mov rsi, [rbx]
    mov [rcx], rsi
    cmp rbx, stdata
    jge _rev

    mov byte [rcx+1], 10
    mov byte [rcx+2], 0
    mov rsi, revbuf
    syscall

    jmp _read
