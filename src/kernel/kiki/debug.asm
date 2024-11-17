bits 64
global __debug_print_regs

extern __debug_printf

section .text

__debug_print_regs:
    push rbp
    mov rbp, rsp

    mov rdi, PRINT_REG_FMT
    mov rsi, [rbp + 16]
    mov rdx, [rbp + 24]
    mov rcx, [rbp + 32]
    mov r8, [rbp + 40]
    mov r9, [rbp + 48]
    mov rax, [rbp + 72]
    push rax
    mov rax, [rbp + 64]
    push rax
    mov rax, [rbp + 56]
    push rax
    xor rax, rax
    call __debug_printf
    add sp, 24

    leave
    ret

section .data

PRINT_REG_FMT  db "Register State:", 10
               db "rax = 0x%lX, rbx = 0x%lX, rcx = 0x%lX, rdx = 0x%lX", 10
               db "rdi = 0x%lX, rsi = 0x%lX, rbp = 0x%lX, rsp = 0x%lX", 10, 0
