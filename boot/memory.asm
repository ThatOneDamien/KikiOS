bits 16

MMAP_ENTRY_CNT equ 0x9000
MMAP_ENTRIES   equ MMAP_ENTRY_CNT + 4
MMAP_MAGIC     equ 0x534D4150


extern boot_error

section .text

global mmap_get
mmap_get:
    mov di, MMAP_ENTRIES
    xor ebx, ebx
    mov edx, MMAP_MAGIC
    mov eax, 0xE820
    mov dword [di + 20], 1
    mov ecx, 24
    int 0x15
    
    ; Check if function is supported
    mov si, MMAP_NOT_SUPPORTED_MSG
    jc boot_error
    
    ; Check if function succeeded
    mov edx, MMAP_MAGIC
    cmp eax, edx
    jne boot_error
    
    ; Check if list was 1 entry long
    test ebx, ebx
    jz boot_error
    
    xor si, si ; Counter
    jmp short .check_long_entry
.loop:
    mov eax, 0xE820
    mov dword [di + 20], 1
    mov ecx, 24
    int 0x15
    jc short .done
    mov edx, MMAP_MAGIC
.check_long_entry:
    jcxz .skipentry
    cmp cl, 24
    jb short .no_long
    test byte [di + 20], 1
    je short .skipentry
.no_long:
    mov ecx, dword [di + 8]
    or ecx, dword [di + 12]
    jz .skipentry
    inc si
    add di, 24
.skipentry:
    test ebx, ebx
    jnz short .loop
.done:
    mov word [MMAP_ENTRY_CNT], si
    clc
    ret

section .rodata

MMAP_NOT_SUPPORTED_MSG db "Failed to produce viable memory map.", 10, 13, 0
