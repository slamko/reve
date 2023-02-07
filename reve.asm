BUF_LEN  equ 0x1000
NEW_LN   equ 0xA
O_CREAT  equ 64
O_RDONLY equ 0   
SYS_EXIT equ 60
ERR_CODE equ -1

section .data
    new_ln db 0xA, 0

section .bss
    stdata resb BUF_LEN
    revbuf resb BUF_LEN
    prev_pos resq 1
    st_pos resq 1
    cbbuf resb 1
   
section .text
    global _start

%macro _sys_write 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro _mexit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro


    ;;  start
    
_start:
    pop r12
    mov r13, r12
    mov r14, 1
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

    xor r14, r14
    mov rax, 2
    mov rsi, 0
    syscall
    
    push rax
    mov rdi, rax
    cmp rdi, 0
    jge _read

    _mexit 1
    
_read:  
    mov qword [prev_pos], stdata

    xor rax, rax
    mov rdi, [rsp]
    mov rsi, stdata
    mov rdx, BUF_LEN
    syscall

    mov rbx, stdata
    mov r15, rax
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

    mov rax, 8
    mov rdi, [rsp]
    mov rsi, [prev_pos]
    sub rsi, stdata
    sub rsi, r15
    mov rdx, 1
    syscall

    jmp _read

_cleanbuf:
    inc rbx
    mov [st_pos], rbx
    mov rdx, rbx
    sub rdx, stdata
    cmp byte [rbx-1], NEW_LN
    je _init_rev

    cmp qword [rsp], 1
    jg _init_rev

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

    mov byte dl, [rbx]
    mov byte [rcx], dl
    inc rcx
    cmp rbx, [prev_pos]
    jl _fin_line

    cmp byte [rbx], 10
    jne _rev

    inc rax
    cmp rax, 1
    jle _rev
    
_fin_line:  
    mov rax, 1
    mov rdi, 1
    mov byte [rcx], NEW_LN
    mov rsi, revbuf

    mov rdx, [st_pos]
    sub rdx, [prev_pos]
    add rdx, 1
    mov byte [revbuf], 0
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
    jne _get_len
      
    jmp _read_args

_restart_io:   
    _sys_write new_ln, 1
    jmp _read
_exit:  
    
    mov rdi, 0
    _mexit 0
    
