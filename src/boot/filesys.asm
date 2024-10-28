bits 16

global DRIVE_NUMBER
global SECS_PER_TRACK
global HEAD_COUNT
global RESERVED_SECS

section .filesys_header
JMP_SHORT        times 3 db 0
OEM_ID           times 8 db 0
BYTES_PER_SEC    times 2 db 0
SECS_PER_CLUS    times 1 db 0
RESERVED_SECS    times 2 db 0
FAT_COUNT        times 1 db 0
ROOT_ENTRY_COUNT times 2 db 0
TOTAL_SECS       times 2 db 0
MEDIA_DESC_TYPE  times 1 db 0
SECS_PER_FAT     times 2 db 0
SECS_PER_TRACK   times 2 db 0
HEAD_COUNT       times 2 db 0
HIDDEN_SECTORS   times 4 db 0
LARGE_SEC_CNT    times 4 db 0

; Extended Boot Record
DRIVE_NUMBER     times 1  db 0 ; Set when booted
                 times 1  db 0 ; Unused Flags
                 times 1  db 0 ; Signature
                 times 4  db 0 ; Unused VolumeID
VOLUME_LABEL     times 11 db 0 ; Exactly 11 bytes
                 times 8  db 0 ; Unused label

extern load_secs_LBA
extern boot_error

global load_kernel
global KERNEL_LOC

section .stage_two_text

ROOT_DIR_BUF equ 0x600
ENTRY_SIZE equ 32
KERNEL_LOC equ 0x10000

check_entries:
    push bx
    push cx
    push si
    push di
    mov bx, ROOT_DIR_BUF
.loop:
    mov ax, -1
    cmp bx, 0x800
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

load_kernel:
    mov si, word [RESERVED_SECS]
    movzx ax, byte [FAT_COUNT]
    mov cx, word [SECS_PER_FAT]
    mul cx
    add si, ax
    mov di, ROOT_DIR_BUF
    mov ax, word [ROOT_ENTRY_COUNT]
    shl ax, 5
    mov bx, word [BYTES_PER_SEC]
    div bx
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
    add ax, 26 ; Offset of first cluster
    mov bx, ax
    mov ax, word [bx] ; ax now contains the starting cluster
    mov dx, 2
    mov si, word [RESERVED_SECS]
    mov di, 0x8500
    call load_secs_LBA
    mov bx, (KERNEL_LOC >> 4) & 0xFFFF
    mov es, bx
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
    call load_secs_LBA
    mov ax, dx
    mov cx, word [BYTES_PER_SEC] 
    mul cx
    add di, ax
    pop ax
    mov bx, 0x8500
    shl ax, 1
    add bx, ax
    mov ax, word [bx]
    cmp ax, 0xFFF8
    jb .loop2
.done:
    mov ax, 0
    mov es, ax
    add sp, 2
    ret
.error:
    mov si, KERNEL_NOT_FOUND
    jmp boot_error

section .stage_two_data
KERNEL_BIN_STR db "KERNEL  BIN"
KERNEL_NOT_FOUND db "Kernel binary not found."
