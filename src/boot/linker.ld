OUTPUT_FORMAT(binary)

INCLUDE "build/env.ld"

SECTIONS 
{
    . = 0x7c00;
    start = .;
    .filesys_header : { *(.filesys_header) }
    .boot_entry     : { *(.boot_entry)     }
    end = .;
    
    ASSERT(end - start <= 512, "Stage one bootloader exceeds 512 bytes")

    . = 0x7DFE;
    .boot_signature : 
    { 
        BYTE(0x55) 
        BYTE(0xAA)
    }

    start = .;
    .stage_two_text : { *(.stage_two_text) }
    .stage_two_data : { *(.stage_two_data) }
    .stage_two_bss  : { *(.stage_two_bss)  }
    end = .;
    ASSERT(RESERVED_SECS >= 1, "Reserved sectors are invalid. Check that the env linkerscript was built correctly.")
    ASSERT(end - start <= 512 * (RESERVED_SECS - 1), "Stage two bootloader exceeds reserved space.")
}

