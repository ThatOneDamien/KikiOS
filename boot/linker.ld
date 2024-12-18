OUTPUT_FORMAT(binary)

__reserved_secs = 4;

SECTIONS 
{
    . = 0x7C00;

    __start = .;
    .filesys_header : { *(.filesys_header) }
    .entry          : { *(.entry)          }
    .boot_sector    : { *(.boot_sector)    }
    __end = .;

    ASSERT(__end - __start <= 510, "Stage one bootloader exceeds 512 bytes.")

    . = 0x7DFE;
    .boot_signature : 
    { 
        BYTE(0x55) 
        BYTE(0xAA) 
    }



    __start = .;
    .text   : { *(.text)   }
    .data   : { *(.data)   }
    .rodata : { *(.rodata) }
    .bss    : { *(.bss)    }
    __end = .;

    ASSERT(__end - __start <= 512 * (__reserved_secs - 1), "Stage two bootloader exceeds reserved space.")
}

