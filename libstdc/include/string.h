#pragma once

#if __WORDSIZE == 64
    typedef unsigned long size_t;
#else
    typedef unsigned int size_t;
#endif

void* memcpy(void* dst, const void* src, size_t count);
