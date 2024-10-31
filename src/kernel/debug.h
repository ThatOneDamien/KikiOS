#ifndef _KIKI_DEBUG_H
#define _KIKI_DEBUG_H

#include "types.h"
#ifdef KIKI_DEBUG

KIKI_BEGIN_EXTERN_C

void        __debug_clear_buf();
void        __debug_putc(char c);
void        __debug_puts(const char* str);
void        __debug_printf(const char* KIKI_RESTRICT fmt, ...);
extern void __debug_print_regs();

void KIKI_NO_RETURN __debug_pstats_and_halt(const char* opt);

KIKI_END_EXTERN_C
#endif

#ifdef KIKI_DEBUG
    #define kclear_print_buf()    __debug_clear_buf()
    #define kputc(c)              __debug_putc(c)
    #define kputs(str)            __debug_puts(str)
    #define kprintf(fmt, ...)     __debug_printf(fmt, ##__VA_ARGS__)
    #define kprint_regs()         __debug_print_regs()
    #define kpstats_and_halt(opt) __debug_pstats_and_halt(opt)
#else
    #define kclear_print_buf()
    #define kputc(c)
    #define kputs(str)
    #define kprintf(fmt, ...)
    #define kprint_regs()
    #define kpstats_and_halt(opt)
#endif // !KIKI_DEBUG
#endif // !_KIKI_DEBUG_H
