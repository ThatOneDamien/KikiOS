OUTPUT_FORMAT(binary)

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
    extra_secs = 2;
    start = .;
    .stage_two_text : { *(.stage_two_text) }
    .stage_two_data : { *(.stage_two_data) }
    .stage_two_bss  : { *(.stage_two_bss)  }
    end = .;
    ASSERT(end - start <= 512 * extra_secs, "Stage two bootloader exceeds reserved space.")
}

