#include <kiki/debug.h>

#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>

static inline char to_upper(char c)
{
    return c >= 'a' && c <= 'z' ? c + ('A' - 'a') : c;
}

static inline char to_lower(char c)
{
    return c >= 'A' && c <= 'Z' ? c + ('a' - 'A') : c;
}


#ifdef KIKI_DEBUG

uint16_t* const VIDEO_BUF = (uint16_t*)0xb8000;
const uint32_t VIDEO_COLS = 80;
const uint32_t VIDEO_ROWS = 25;

uint32_t cur_col = 0, cur_row = 0;

/**
 * @brief Clear the video buffer
 */
void kernel_clear_buf()
{
    for(uint32_t i = 0; i < VIDEO_ROWS * VIDEO_COLS; ++i)
        VIDEO_BUF[i] = 0x20;
    cur_col = 0;
    cur_row = 0;
}

/**
 * @brief Prints character 'c' to the screen and
 * scrolls if necessary.
 * @param c The character to be printed
 */
void kernel_putc(char c)
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

/**
 * @brief Prints string str to the screen
 * @param str The string to be printed
 */
void kernel_puts(const char* str)
{
    while(*str != '\0')
        kernel_putc(*(str++));
}

enum IntegerLength
{
    INT_LENGTH_NONE      = 0,
    INT_LENGTH_CHAR      = 1,
    INT_LENGTH_SHORT     = 2,
    INT_LENGTH_INT       = 4,
    INT_LENGTH_LONG      = 8,
    INT_LENGTH_LONG_LONG = 9
};

static void print_num(void* num, enum IntegerLength length, bool is_signed, uint8_t base,
                      bool upper)
{
    // Max string size is a binary string of 64 bit int
    char buffer[64];
    int pos = 0;
    int negative = 0;
    uint64_t final = 0;
    static const char CONVERSION[16] = "0123456789abcdef";

    switch(length)
    {
    case INT_LENGTH_CHAR: {
        if(is_signed)
        {
            int8_t n = *(int8_t*)num;
            negative = n < 0;
            final = negative ? -n : n;
        }
        else
            final = *(uint8_t*)num;
        break;
    }
    case INT_LENGTH_SHORT: {
        if(is_signed)
        {
            int16_t n = *(int16_t*)num;
            negative = n < 0;
            final = negative ? -n : n;
        }
        else
            final = *(uint16_t*)num;
        break;
    }
    case INT_LENGTH_INT: {
        if(is_signed)
        {
            int32_t n = *(int32_t*)num;
            negative = n < 0;
            final = negative ? -n : n;
        }
        else
            final = *(uint32_t*)num;
        break;
    }
    case INT_LENGTH_LONG:
    case INT_LENGTH_LONG_LONG: {
        if(is_signed)
        {
            int64_t n = *(int64_t*)num;
            negative = n < 0;
            final = negative ? -n : n;
        }
        else
            final = *(uint64_t*)num;
        break;
    }
    default:
        // KERNEL PANIC
        break;
    }

    while(final != 0)
    {
        buffer[pos] = CONVERSION[final % base];
        final /= base;
        ++pos;
    }

    if(negative)
        kernel_putc('-');

    for(int i = pos - 1; i >= 0; --i)
        kernel_putc(upper ? to_upper(buffer[i]) : buffer[i]);
    if(pos == 0)
        kernel_putc('0');
}

void kernel_printf(const char* KIKI_RESTRICT fmt, ...)
{
    if(!fmt)
        return;
    va_list args;
    va_start(args, fmt);

    bool is_escape = false;
    enum IntegerLength length = INT_LENGTH_NONE;
    while(*fmt)
    {
        if(is_escape)
        {
            switch(*fmt)
            {
            case 'd':
            case 'i': {
                uint64_t i = va_arg(args, uint64_t);
                is_escape = false;
                print_num(&i, length == INT_LENGTH_NONE ? INT_LENGTH_INT : length, true, 10, false);
                length = INT_LENGTH_NONE;
                break;
            }
            case 'o': {
                uint64_t i = va_arg(args, uint64_t);
                is_escape = false;
                print_num(&i, length == INT_LENGTH_NONE ? INT_LENGTH_INT : length, false, 8, false);
                length = INT_LENGTH_NONE;
                break;
            }
            case 'u': {
                uint64_t i = va_arg(args, uint64_t);
                is_escape = false;
                print_num(&i, length == INT_LENGTH_NONE ? INT_LENGTH_INT : length, false, 10,
                          false);
                length = INT_LENGTH_NONE;
                break;
            }
            case 'x':
            case 'X': {
                uint64_t i = va_arg(args, uint64_t);
                is_escape = false;
                print_num(&i, length == INT_LENGTH_NONE ? INT_LENGTH_INT : length, false, 16,
                          *fmt == 'X');
                length = INT_LENGTH_NONE;
                break;
            }
            case 's': {
                const char* str = va_arg(args, const char*);
                is_escape = false;
                kernel_puts(str ? str : "(null)");
                break;
            }
            case '%': {
                is_escape = false;
                kernel_putc('%');
                break;
            }
            case 'l': {
                if(length == INT_LENGTH_NONE)
                    length = INT_LENGTH_LONG;
                else if(length == INT_LENGTH_LONG)
                    length = INT_LENGTH_LONG_LONG;
                else
                    kernel_puts("BAD FORMAT.");
                break;
            }
            case 'h': {
                if(length == INT_LENGTH_NONE)
                    length = INT_LENGTH_SHORT;
                else if(length == INT_LENGTH_SHORT)
                    length = INT_LENGTH_CHAR;
                else
                    kernel_puts("BAD FORMAT.");
                break;
            }
            default:
                kernel_puts("BAD FORMAT.");
            }
        }
        else if(*fmt == '%')
            is_escape = true;
        else
            kernel_putc(*fmt);
        ++fmt;
    }
    if(is_escape)
        kernel_puts("BAD FORMAT.");
    va_end(args);
}

void KIKI_NO_RETURN __debug_pstats_and_halt()
{
    kernel_puts("KERNEL HALT TRIGGERED:\n");
    kernel_print_regs();

    KIKI_UNREACHABLE()
}
#endif // KIKI_DEBUG
