#ifndef _KIKI_COMPDEF_H
#define _KIKI_COMPDEF_H

#ifdef __cplusplus
    #define KIKI_BEGIN_EXTERN_C extern "C" {
    #define KIKI_END_EXTERN_C }
#else
    #define KIKI_BEGIN_EXTERN_C
    #define KIKI_END_EXTERN_C
#endif

#ifdef __GNUC__
    #define KIKI_UNREACHABLE() __builtin_unreachable();
    #define KIKI_NO_RETURN     __attribute__((noreturn))
    #define KIKI_UNUSED        __attribute__((unused))
    #define KIKI_RESTRICT      __restrict
#else
    #define KIKI_UNREACHABLE()
    #define KIKI_NO_RETURN
    #define KIKI_UNUSED
    #define KIKI_RESTRICT
#endif

#endif // !_KIKI_COMPDEF_H
