#include <kiki/compdef.h>
#include <kiki/debug.h>
#include <kiki/mmap.h>

__attribute__((no_stack_protector, no_sanitize_address, section(".kernel_entry")))
void KIKI_NO_RETURN kernel_start()
{
    kernel_clear_buf();

    mmap_init();

    __asm__("hlt");
    KIKI_UNREACHABLE()
}
