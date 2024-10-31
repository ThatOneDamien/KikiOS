#include "compdef.h"
#include "debug.h"

void KIKI_NO_RETURN __attribute__((section(".kernel_entry"))) kernel_start()
{
    kclear_print_buf();
    kputs("Brother this is so gay!");
    asm("hlt");
    KIKI_UNREACHABLE()
}
