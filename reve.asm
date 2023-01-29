BUF_LEN  equ 0x1000
NEW_LN   equ 10
O_CREAT  equ 64
O_RDONLY equ 0   
SYS_EXIT equ 60
ERR_CODE equ -1

;; magic number
FIRST_LN equ 0xf7f7f7
    
section .data

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    prev_pos resq 1
    st_pos resq 1
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

_mexit: 
    mov rax, SYS_EXIT
    syscall
    ret
    
_start:
    pop r12
    mov r13, r12
    pop rax
    xor rdi, rdi
    push 0
    cmp r12, 1
    je _read

_read_args: 
    dec r13
    jz _exit
    
    pop rdi
    pop rdi

    mov qword [prev_pos], stdata
    mov r14, FIRST_LN
    mov rax, 2
    mov rsi, 0
    syscall
    
    push rax
    mov rdi, rax
    cmp rdi, 0
    jge _read

    call _mexit
    
_read:  
    xor rax, rax
    pop rdi
    push rdi
    mov rsi, stdata
    mov rdx, BUF_LEN
    syscall

    mov rbx, stdata
    add rbx, rax
    mov byte [rbx], 0
    mov rbx, stdata

_get_len:   
    mov rdx, BUF_LEN + stdata
_len:
    mov cl, [rbx]
    cmp cl, NEW_LN
    je _cleanbuf

    inc rbx
    cmp rbx, rdx
    jle _len
    
_cleanbuf:
    mov [st_pos], rbx
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
    mov rdx, rbx
    sub rdx, stdata - 2
    mov rcx, revbuf

_rev:
    dec rbx

    mov dl, [rbx]
    mov [rcx], dl
    inc rcx
    cmp rbx, [prev_pos]
    jl _fin_line

    cmp byte [rbx], 10
    jne _rev
    
_fin_line:  
    call _sys_write_init
    mov byte [rcx], NEW_LN
    mov byte [rcx+1], 0
    mov rsi, revbuf

    mov rdx, [st_pos]
    sub rdx, [prev_pos]
    cmp qword r14, FIRST_LN
    jne _s_call
    add rdx, 2
_s_call:    
    syscall

    xor r14, r14
    cmp r12, 1
    je _restart_io

    mov qword rbx, [st_pos]
    mov qword [prev_pos], rbx
    inc rbx

    cmp byte [rbx], 0
    je _read_args

    jmp _get_len

_restart_io:   
    jmp _read
_exit:  
   mov rdi, 0
   call _mexit
