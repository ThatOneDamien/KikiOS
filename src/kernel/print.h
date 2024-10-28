#pragma once
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

void clear_buf();
void putc(char c);
void puts(const char* str);

#ifdef __cplusplus
}
#endif
