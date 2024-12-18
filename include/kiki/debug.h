#ifndef _KIKI_DEBUG_H
#define _KIKI_DEBUG_H

#include <kiki/compdef.h>

KIKI_BEGIN_EXTERN_C

void kernel_clear_buf();
void kernel_putc(char c);
void kernel_puts(const char* str);
void __attribute__((format(printf, 1, 2))) kernel_printf(const char* KIKI_RESTRICT fmt, ...);

extern void         kernel_print_regs();
void KIKI_NO_RETURN __debug_pstats_and_halt();

KIKI_END_EXTERN_C
#endif
