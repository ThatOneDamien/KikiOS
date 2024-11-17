#include "limits.h"

#include "kiki/compdef.h"
#include "kiki/debug.h"

struct MemRegion
{
    uint64_t base_addr;
    uint64_t length;
    uint32_t type;
    uint32_t ACPI;
};

uint32_t* entry_cnt = (uint32_t*)0x9000;
struct MemRegion* entries = (struct MemRegion*)0x9004;

const char* type_to_str(uint32_t type)
{
    switch(type)
    {
    case 1:
        return "Usable";
    case 2:
        return "Reserved - Unusable";
    case 3:
        return "ACPI Reclaimable";
    case 4:
        return "ACPI NVS Memory";
    case 5:
        return "Bad Memory Region";
    }
    return NULL;
}

void KIKI_NO_RETURN __attribute__((section(".kernel_entry"))) kernel_start()
{
    kclear_print_buf();
    kprintf("ENTRY CNT: %u\n", *entry_cnt);
    for(uint32_t i = 0; i < *entry_cnt; ++i)
        kprintf("Entry %i: BASE: %lX LENGTH: %lX TYPE: %s\n", i, entries[i].base_addr, entries[i].length, type_to_str(entries[i].type));
    kprint_regs();
    __asm__("hlt");
    KIKI_UNREACHABLE()
}
