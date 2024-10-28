#include "print.h"
#include "compdef.h"

void NO_RETURN __attribute__((section(".kernel_entry"))) kernel_start()
{
    clear_buf();
    puts("This is the Kiki Kernel");
    asm("hlt");
    UNREACHABLE()
}
