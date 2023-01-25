BUF_LEN  equ 0x1000
NEW_LN   equ 10
O_CREAT  equ 64
O_RDONLY equ 0   
SYS_EXIT equ 60
    
section .data

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    st_pos resq 1
    prev_pos resq 1
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
    mov rdi, 0
    syscall
    ret
    
_start:
    pop r12
    mov r13, r12
    pop rax
    xor rdi, rdi
    push 0
    mov qword [prev_pos], stdata

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
    cmp rdi, -1
    jne _read

    jmp _exit

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
    je init_rev

    inc rbx
    cmp rbx, rdx
    jle _len

init_rev:  
    mov [st_pos], rbx
    call _sys_write_init
    mov rdx, rbx
    sub rdx, stdata - 2
    mov rcx, revbuf

_rev:
    dec rbx

    mov rsi, [rbx]
    mov [rcx], rsi
    inc rcx
    cmp rbx, [prev_pos]
    jg _rev

    mov byte [rcx], NEW_LN
    mov byte [rcx+1], 0
    mov rsi, revbuf
    syscall

    cmp r12, 1
    je _restart

    inc qword [st_pos]
    mov qword rbx, [st_pos]
    mov qword [prev_pos], rbx

    cmp byte [rbx], 0
    je _read_args

    inc rbx
    jmp _get_len

_restart:   
    jmp _read
_exit:  
    call _mexit
