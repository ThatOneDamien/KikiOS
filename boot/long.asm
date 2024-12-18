bits 16

PAGE_SIZE  equ 0x1000
PML4T_LOC  equ 0x1000
PDPT_LOC   equ 0x2000
PDT_LOC    equ 0x3000
PT_LOC     equ 0x4000
PAGE_FLAGS equ 0b11   ; Present, readable, and writable


extern boot_error

section .text

global enter_long_mode
enter_long_mode:
    ; Check for CPUID support
    pushfd
    pop eax

    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx

    ; If bit 21 is unaltered, CPUID is not supported don't boot. 
    mov si, NO_CPUID_MSG
    jz boot_error

    ; CPUID supported, check it for long mode support
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    mov si, NO_LONG_MODE_MSG
    jb boot_error ; No extended function of CPUID and therefore no long mode, don't boot

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz boot_error ; Long mode not supported



    ; Check A20 line
    mov ax, 0xFFFF
    mov ds, ax
    mov di, 0x500
    mov si, 0x510

    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF

    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al

    mov ax, 0
    mov ds, ax

    ; If memory wraps, A20 line is disabled. For now we don't boot
    ; in the near future I will actually enable the A20 line.
    je boot_error


    ; Enable 4-leveled paging for long mode
    mov edi, PML4T_LOC ; Put tables at 0x1000 so they are page aligned
    mov cr3, edi
    xor eax, eax
    mov ecx, PAGE_SIZE
    rep stosd          ; Zero out all 4 levels of page tables
    mov edi, cr3

    mov dword [edi], PDPT_LOC | PAGE_FLAGS
    add edi, PAGE_SIZE
    mov dword [edi], PDT_LOC | PAGE_FLAGS
    add edi, PAGE_SIZE
    mov dword [edi], PT_LOC | PAGE_FLAGS
    add edi, PAGE_SIZE

    mov ecx, 512 ; 512 entries in the page table
    mov ebx, PAGE_FLAGS

.PT_Loop:
    mov dword [edi], ebx
    add ebx, PAGE_SIZE
    add edi, 8
    dec ecx
    jnz .PT_Loop

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31 | 1 << 0     ; Set the PG-bit, which is the 31nd bit, and the PM-bit, which is the 0th bit.
    mov cr0, eax

    lgdt [GDT.Pointer]
    jmp GDT.Code:test


extern KERNEL_LOC
bits 64
test:
    cli
    mov ax, GDT.Data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, KERNEL_LOC
    mov rbp, rsp

    ; Hack return to pass control to the kernel
    push rsp
    ret



; GDT Flags
; Access bits
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5


section .data
align 8
GDT:
.Null: equ $ - GDT
    dq 0
.Code: equ $ - GDT
    dd 0xFFFF                           ; Limit & Base (low, bits 0-15)
    db 0                                ; Base (mid, bits 16-23)
    db PRESENT | NOT_SYS | EXEC | RW    ; Access
    db GRAN_4K | LONG_MODE | 0xF        ; Flags & Limit (high, bits 16-19)
    db 0                                ; Base (high, bits 24-31)
.Data: equ $ - GDT
    dd 0xFFFF                           ; Limit & Base (low, bits 0-15)
    db 0                                ; Base (mid, bits 16-23)
    db PRESENT | NOT_SYS | RW           ; Access
    db GRAN_4K | SZ_32 | 0xF            ; Flags & Limit (high, bits 16-19)
    db 0                                ; Base (high, bits 24-31)
.Pointer:
    dw $ - GDT - 1
    dq GDT


section .rodata

NO_CPUID_MSG     db "CPUID instruction not supported.", 0
NO_LONG_MODE_MSG db "Unable to enter long mode.", 0
