#include <string.h>

void* memcpy(void* dst, const void* src, size_t count) {
    void* original_dst = dst;
    unsigned char* dst_bytes = dst;
    const unsigned char* src_bytes = src;
    while (count) {
        *dst_bytes++ = *src_bytes++;
        --count;
    }
    return original_dst;
}
