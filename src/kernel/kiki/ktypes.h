#ifndef _KIKI_TYPES_H
#define _KIKI_TYPES_H

#include "compdef.h"
#include "limits.h"

#ifndef __cplusplus
#define bool _Bool
#define false 0
#define true  1
#define NULL (void*)0
#else
#define NULL 0
#endif

typedef signed char  int8_t;
typedef signed short int16_t;
typedef signed int   int32_t;
typedef signed long  int64_t;

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  uint64_t;

typedef unsigned long size_t;
typedef unsigned long uintptr_t;

#endif // !_KIKI_TYPES_H
