#include <kiki/mmap.h>

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include <kiki/debug.h>
#include <kiki/page_types.h>
#include <kiki/round.h>

// Don't use anything below 1MiB, this is the kernel and other boot stuff.
#define USABLE_MEM_BASE 0x100000 

typedef enum
{
    MemRegionInvalid         = 0,
    MemRegionUsable          = 1,
    MemRegionACPIReclaimable = 2,
    MemRegionACPINVS         = 3,
    MemRegionBadMemory       = 4
} MemRegionType;

typedef struct
{
    uint64_t base_addr;
    uint64_t length;
    MemRegionType type;
    uint32_t acpi_extended;
} BootMMapEntry;


static uint32_t* mmap_entry_cnt = (uint32_t*)BOOT_MMAP_ENTRY_CNT;
static BootMMapEntry* mmap = (BootMMapEntry*)BOOT_MMAP_LOCATION;

void mmap_init()
{
    size_t total_pages = 0;
    for(uint32_t i = 0; i < *mmap_entry_cnt; ++i)
    {
        uint64_t region_end = mmap[i].base_addr + mmap[i].length; 
        if(mmap[i].type == MemRegionUsable && region_end > USABLE_MEM_BASE)
            total_pages += (mmap[i].base_addr >= USABLE_MEM_BASE ? mmap[i].length
                                              : region_end - USABLE_MEM_BASE) / KIKI_PAGE_SIZE;
    }
    kernel_printf("Total Pages Available: %lu\n", total_pages);
}
