bits 16

STAGE_TWO_LOC equ 0x7E00


; Long Mode
extern enter_long_mode 

; Filesystem externs
extern DRIVE_NUMBER
extern SECS_PER_TRACK
extern HEAD_COUNT
extern RESERVED_SECS

extern load_kernel

section .boot_entry
global load_secs_LBA
global boot_error

start:
    ; Set segment registers to known state (zeroed out)
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack just below boot sector for now
    mov sp, 0x7C00
    mov bp, sp


    push word ax
    push word .jumped
    retf

.jumped:
    mov byte [DRIVE_NUMBER], dl

    mov si, DISK_ERROR_MSG
    ; Query BIOS for sectors per track and head count of the drive number in dl
    mov ah, 8
    xor di, di
    stc
    int 0x13
    jc boot_error
    and cl, 0x3F
    mov byte [SECS_PER_TRACK], cl
    mov al, dh
    and ax, 0xFF
    inc ax
    mov word [HEAD_COUNT], ax

    ; Load stage 2 boot loader stored
    ; in the reserved sectors of the fs
    mov di, STAGE_TWO_LOC
    mov si, 1
    mov dx, word [RESERVED_SECS]
    dec dx
    call load_secs_LBA


    call load_kernel
    jmp enter_long_mode


halt_proc:
    cli
    hlt
boot_error:
    call puts
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0

; Load sectors from boot disk with LBA addressing
; Parameters:
;   es:di - destination buffer location in memory
;   si - 16 bit starting LBA address
;   dx - 16 bit number of sectors to be read
load_secs_LBA:
    push eax
    push si
    push dx
    push dword 0
    push word 0
    push word si
    push word es
    push word di
    push word dx
    push word 0x10
.read:
    mov si, sp
    mov ah, 0x42
    mov dl, byte [DRIVE_NUMBER]
    stc
    int 0x13
    jc .reset_disk

.done:
    add sp, 16
    pop dx
    pop si
    pop eax
    ret

.reset_disk:
    xor ah, ah
    int 0x13
    jnc .read
    mov si, DISK_ERROR_MSG
    jmp boot_error

;
; Prints string
; Paramaters:
;   ds:si - Null terminated string buffer to be printed
;
puts:
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

DISK_ERROR_MSG   db "Error resetting/reading disk.", 0
