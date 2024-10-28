#include "print.h"

uint16_t* const VIDEO_BUF = (uint16_t*)0xb8000;
const uint32_t VIDEO_COLS = 80;
const uint32_t VIDEO_ROWS = 25;

uint32_t cur_col = 0, cur_row = 0;

void clear_buf()
{
    for(uint32_t i = 0; i < VIDEO_ROWS * VIDEO_COLS; ++i)
        VIDEO_BUF[i] = 0x20;
    cur_col = 0;
    cur_row = 0;
}

void putc(char c)
{
    if(cur_row >= VIDEO_ROWS)
    {
        cur_row = VIDEO_ROWS - 1;
        for(uint32_t i = 0; i < (VIDEO_ROWS - 1) * VIDEO_COLS; ++i)
            VIDEO_BUF[i] = VIDEO_BUF[i + VIDEO_COLS];
    }
    VIDEO_BUF[cur_col + cur_row * VIDEO_COLS] = 0x0700 + (uint8_t)c;
    ++cur_col;
    if(cur_col >= VIDEO_COLS)
    {
        cur_col = 0;
        ++cur_row;
    }
}

void puts(const char* str)
{
    while(*str != '\0')
        putc(*(str++));
}
