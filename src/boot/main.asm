bits 16

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

extern enter_long_mode 


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
    mov di, 0x7E00
    mov si, 1
    mov dx, word [RESERVED_SECS]
    call load_secs_LBA

    
    jmp enter_long_mode
    mov si, UNKNOWN_BOOT_MSG
boot_error:
    call puts
    mov ah, 0
    int 16h
    jmp 0FFFFh:0

; Load sectors from boot disk with LBA addressing
; Parameters:
;   di - 16 bit destination location in memory
;   si - 16 bit starting LBA address
;   dx - 16 bit number of sectors to be read
load_secs_LBA:
    push eax
    xor eax, eax
    push dword eax
    push word ax 
    push word si
    push word ax
    push word di
    push word dx
    mov ax, 0x10
    push word ax

.read:
    mov si, sp
    mov ah, 0x42
    mov dl, byte [DRIVE_NUMBER]
    stc
    int 0x13
    jc .reset_disk

.done:
    add sp, 16
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
UNKNOWN_BOOT_MSG db "Unknown boot error.", 0 
