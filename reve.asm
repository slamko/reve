BUF_LEN  equ 0x1000
NEW_LN   equ 10
O_CREAT  equ 64
O_RDONLY equ 0   
    
section .data

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    cbbuf resb 1
   
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
    pop r8
    pop rax
    xor rdi, rdi
    cmp r8, 1
    je _read

_read_args: 
    pop rdi

    mov rax, 2
    mov rsi, 0
    syscall
    
    push rax
    mov rdi, rax
    cmp rdi, -1
    jne _read

    call _exit
    
    push 0
_read:  
    xor rax, rax
    pop rdi
    push rdi
    mov rsi, stdata
    mov rdx, BUF_LEN
    syscall

    mov rax, 1
    mov rdx, BUF_LEN
    mov rsi, 1
    mov rdi, stdata
    syscall

    mov rbx, stdata
    mov rdx, BUF_LEN + stdata

_len:
    mov cl, [rbx]
    cmp cl, NEW_LN
    je _cleanbuf

    inc rbx
    cmp rbx, rdx
    jle _len
    
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

    cmp byte [cbbuf], NEW_LN
    jne _cbloop

_init_rev:  
    call _sys_write_init
    mov rdx, rbx
    sub rdx, stdata - 2
    mov rcx, revbuf

_rev:
    dec rbx

    mov rsi, [rbx]
    mov [rcx], rsi
    inc rcx
    cmp rbx, stdata
    jge _rev

    mov byte [rcx], NEW_LN
    mov byte [rcx+1], 0
    mov rsi, revbuf
    syscall
    
    jmp _read
    call _exit
