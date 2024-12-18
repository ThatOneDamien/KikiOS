bits 16

extern load_secs_LBA
extern boot_error

extern RESERVED_SECS
extern FAT_COUNT
extern SECS_PER_FAT
extern ROOT_ENTRY_COUNT
extern SECS_PER_CLUS
extern BYTES_PER_SEC

section .text

ENTRY_SIZE   equ 32
ROOT_DIR_BUF equ 0x600
FAT_BUF      equ 0x800

global KERNEL_LOC
KERNEL_LOC equ 0x10000

check_entries:
    push bx
    push cx
    push si
    push di
    mov bx, ROOT_DIR_BUF
.loop:
    push ax
    push bx
    mov ah, 0xe
    mov al, 'H'
    xor bx, bx 
    int 0x10
    pop bx
    pop ax

    mov ax, -1
    cmp bx, FAT_BUF ; Once we reach the fat buf, stop loop
    jnb .end
    mov cl, byte [bx]
    mov ax, -2
    cmp cl, 0
    jz .end

    mov ax, bx
    mov si, ax
    add bx, ENTRY_SIZE
    mov cx, 11
    mov di, KERNEL_BIN_STR
    repz cmpsb
    jne .loop
.end:
    pop di
    pop si
    pop cx
    pop bx
    ret


global load_kernel
load_kernel:
    mov si, word [RESERVED_SECS]
    movzx ax, byte [FAT_COUNT]
    mov cx, word [SECS_PER_FAT]
    mul cx
    add si, ax
    mov di, ROOT_DIR_BUF
    mov ax, word [ROOT_ENTRY_COUNT]
    
    ; Here we are assuming that the sector size is 512 bytes
    ; because there are other areas of the code that would
    ; also break if that wasn't the case. We shr by 4 because
    ; 512 / 32 = 16
    shr ax, 4
    mov cx, ax
    add cx, si
    push cx
    mov dx, 1 ; Read one sector at a time
.loop:
    cmp si, cx
    ja .done
    call load_secs_LBA
    inc si
    call check_entries
    cmp ax, -2
    je .error
    cmp ax, -1
    je .loop
    ; Binary found, and its entry location in the buf is stored in ax
    mov di, ax
    mov ax, word [di + 26] ; ax now contains the starting cluster
    mov di, KERNEL_LOC >> 4
    mov es, di
    mov di, KERNEL_LOC & 0xF
.loop2:
    push ax
    movzx cx, byte [SECS_PER_CLUS]
    sub ax, 2
    mul cx
    mov si, ax
    mov bx, sp
    add si, word [bx + 2]
    mov dx, cx
    call load_secs_LBA ; Load a kernel cluster
    mov ax, dx
    mov cx, word [BYTES_PER_SEC] 
    mul cx
    mov cx, ax
    neg cx
    cmp di, cx
    jb .no_carry
    mov cx, es
    add cx, 0x1000
    mov es, cx
.no_carry:
    add di, ax
    pop ax

    ; Load the needed FAT sector and get next cluster
    push di
    mov dx, 1
    mov di, FAT_BUF
    mov si, ax
    shr si, 8 ; 256 entries per sector of fat
    add si, word [RESERVED_SECS]
    push word es
    xor bx, bx
    mov es, bx
    call load_secs_LBA
    pop word es
    and ax, 0xFF
    shl ax, 1
    add di, ax
    mov ax, word [di]
    pop di
    cmp ax, 0xFFF8
    jb .loop2
.done:
    xor ax, ax
    mov es, ax
    add sp, 2
    ret
.error:
    mov si, KERNEL_NOT_FOUND
    jmp boot_error

section .rodata
KERNEL_BIN_STR   db "KERNEL  BIN"
KERNEL_NOT_FOUND db "Kernel binary not found."
