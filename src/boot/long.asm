bits 16

PAGE_SIZE  equ 0x1000
PML4T_LOC  equ 0x1000
PDPT_LOC   equ 0x2000
PDT_LOC    equ 0x3000
PT_LOC     equ 0x4000
PAGE_FLAGS equ 0b11   ; Present, readable, and writable

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

GDT      equ 0x500
GDT_NULL equ 0x0
GDT_CODE equ 0x8
GDT_DATA equ 0x10
GDT_TSS  equ 0x18

section .stage_two_text
global enter_long_mode
extern boot_error
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

    ; If bit 21 is unaltered, don't boot. Maybe later I'll add support for
    ; 32 bit but for now I want to only work in 64 bit
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

    ; Copy entries from GDT loaded from reserved sectors to
    ; its permanent location at 0x500 in memory.
    mov si, TEMP_GDT
    mov di, GDT
    mov ecx, 16
    rep movsw
    
    lgdt [TEMP_GDT.Pointer]
    jmp GDT_CODE:test



extern KERNEL_LOC
bits 64
test:
    cli
    mov ax, GDT_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov rsp, 0x7c00
    mov rbp, rsp

    cmp byte [KERNEL_LOC], 0x55
    jne .wrong

    push KERNEL_LOC
    ret
.wrong:
    mov rax, 0x1F4C1F4C1F4C1F4C
    mov qword [0xb8000], rax
    hlt

section .stage_two_data
TEMP_GDT:
    ; NULL
        dq 0
    ; CODE
        dd 0xFFFF                           ; Limit & Base (low, bits 0-15)
        db 0                                ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | EXEC | RW    ; Access
        db GRAN_4K | LONG_MODE | 0xF        ; Flags & Limit (high, bits 16-19)
        db 0                                ; Base (high, bits 24-31)
    ; DATA
        dd 0xFFFF                           ; Limit & Base (low, bits 0-15)
        db 0                                ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | RW           ; Access
        db GRAN_4K | SZ_32 | 0xF            ; Flags & Limit (high, bits 16-19)
        db 0                                ; Base (high, bits 24-31)
    ; TSS
        dd 0x00000068
        dd 0x00CF8900
    .Pointer:
        dw $ - TEMP_GDT - 1
        dq GDT

NO_CPUID_MSG     db "CPUID instruction not supported.", 0
NO_LONG_MODE_MSG db "Unable to enter long mode.", 0
