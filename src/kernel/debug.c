#ifdef KIKI_DEBUG

    #include "debug.h"
    #include "types.h"

uint16_t* const VIDEO_BUF  = (uint16_t*)0xb8000;
const uint32_t  VIDEO_COLS = 80;
const uint32_t  VIDEO_ROWS = 25;

uint32_t cur_col = 0, cur_row = 0;

void __debug_clear_buf()
{
    for(uint32_t i = 0; i < VIDEO_ROWS * VIDEO_COLS; ++i)
        VIDEO_BUF[i] = 0x20;
    cur_col = 0;
    cur_row = 0;
}

void __debug_putc(char c)
{
    if(cur_row >= VIDEO_ROWS)
    {
        for(uint32_t i = 0; i < (VIDEO_ROWS - 1) * VIDEO_COLS; ++i)
            VIDEO_BUF[i] = VIDEO_BUF[i + VIDEO_COLS];
        cur_row = VIDEO_ROWS - 1;
    }

    if(c == '\n')
    {
        cur_col = 0;
        ++cur_row;
    }
    else
    {
        VIDEO_BUF[cur_col + cur_row * VIDEO_COLS] = 0x0700 + (uint8_t)c;
        ++cur_col;
        if(cur_col == VIDEO_COLS)
        {
            cur_col = 0;
            ++cur_row;
        }
    }
}

void __debug_puts(const char* str)
{
    while(*str != '\0')
        __debug_putc(*(str++));
}

static const char CONVERSION[16] = "0123456789ABCDEF";

enum IntegerLength
{
    INT_LENGTH_CHAR  = 1,
    INT_LENGTH_SHORT = 2,
    INT_LENGTH_INT   = 4,
    INT_LENGTH_LONG  = 8
};

static void print_num(uint64_t* num, enum IntegerLength length, bool is_signed, uint8_t base)
{
    // Max string size is a binary string of 64 bit int
    char   buffer[64];
    size_t pos      = 0;
    int    negative = is_signed && (*num & (1 << (length - 1)));
    uint64_t final  = *num & (is_signed );
}

void __debug_printf(const char* KIKI_RESTRICT fmt, ...) {}

void KIKI_NO_RETURN __debug_pstats_and_halt(const char* opt)
{
    __debug_puts("KERNEL HALT TRIGGERED:\n");
    __debug_print_regs();
    if(opt != NULL)
        __debug_puts(opt);

    KIKI_UNREACHABLE()
}
#endif // KIKI_DEBUG
