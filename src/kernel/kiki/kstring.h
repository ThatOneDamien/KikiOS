#ifndef _KIKI_STRING_H
#define _KIKI_STRING_H

static inline char to_upper(char c)
{
    return c >= 'a' && c <= 'z' ? c + ('A' - 'a') : c;
}

static inline char to_lower(char c)
{
    return c >= 'A' && c <= 'Z' ? c + ('a' - 'A') : c;
}

#endif //!_KIKI_STRING_H
