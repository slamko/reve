BUF_LEN  equ 0x10
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
    xor rax, rax
    xor rdi, rdi
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

    mov rax, 2
    mov rsi, 0
    syscall
    
    push rax
    mov rdi, rax
    cmp rdi, 0
    jge _read

    call _mexit
    
_read:  
    xor r14, r14
    mov qword [prev_pos], stdata

    xor rax, rax
    mov rdi, [rsp]
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
    jl _len
    
_cleanbuf:
    inc rbx
    mov [st_pos], rbx
    mov rdx, rbx
    sub rdx, stdata
    cmp byte [rbx], NEW_LN
    je _init_rev

    cmp qword [rsp], 2
    jge _init_rev

_cbloop:
    xor rax, rax
    xor rdi, rdi
    mov rsi, cbbuf
    mov rdx, 1
    syscall

    cmp byte [cbbuf], NEW_LN
    jne _cbloop

_init_rev:  
    mov rdx, rbx
    sub rdx, stdata - 2
    mov rcx, revbuf
    xor rax, rax

_rev:
    dec rbx

    mov dl, [rbx]
    mov [rcx], dl
    inc rcx
    cmp rbx, [prev_pos]
    jl _fin_line

    cmp byte [rbx], 10
    jne _rev

    inc rax
    cmp rax, 1
    jle _rev
    
_fin_line:  
    call _sys_write_init
    mov byte [rcx], 0
    mov rsi, revbuf

    mov rdx, [st_pos]
    sub rdx, [prev_pos]
    test r14, r14
    jnz _s_call
    add rdx, 1

_s_call:    
    syscall

    inc r14
    cmp r12, 1
    je _restart_io

    mov qword rbx, [st_pos]
    mov qword [prev_pos], rbx

    mov rdx, stdata + BUF_LEN
    cmp rbx, rdx
    jge _read

    cmp byte [rbx], 0
    je _read_args

    jmp _get_len

_restart_io:   
    jmp _read
_exit:  
   mov rdi, 0
   call _mexit
