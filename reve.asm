BUF_LEN  equ 4096
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
    pop rax
    cmp rax, 1
    mov r8, 0
    je _read

    pop rax


_read_args    
    pop rdi

    mov rax, 2
    mov rsi, O_RDONLY
    syscall
    
    mov r8, rax
    mov rax, 0
    jmp _read_file
    
_read:  
    call _sys_read_init
    jmp _read_data
_read_file:
_read_data: 
    mov rsi, stdata
    mov rdx, BUF_LEN
    syscall

    mov rbx, stdata
    mov rdx, BUF_LEN
    add rdx, stdata

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
    sub rdx, stdata
    add rdx, 2
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
