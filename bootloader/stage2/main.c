#include <stdint.h>

void _start() {
    uint16_t* video_ram = (uint16_t*)0xB8000;
    video_ram[0] = 0x4141;

    while (1) {}
}
