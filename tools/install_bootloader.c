#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define DISK_SIGNATURE_OFFSET 440
#define DISK_SIGNATURE_SIZE 6

#define PARTITION_TABLE_OFFSET 446
#define PARTITION_TABLE_SIZE 64

#define BOOTLOADER_SIZE 32768

void print_usage() {
    puts("Usage: install_bootloader <disk_image> <bootloader>");
    puts("Bootloader has to be exactly 32768 bytes long");
}

int main(const int argc, const char* argv[]) {
    if (argc != 3) {
        print_usage();
        return 1;
    }

    const char* disk_image_path = argv[1];
    const char* bootloader_path = argv[2];

    FILE* disk_image_file = fopen(disk_image_path, "rb+");
    if (disk_image_file == NULL) {
        fprintf(stderr, "error: failed to open the disk image \"%s\"\n", disk_image_path);
        return 1;
    }

    FILE* bootloader_file = fopen(bootloader_path, "rb");
    if (bootloader_file == NULL) {
        fprintf(stderr, "error: failed to open the bootloader \"%s\"\n", bootloader_path);
        fclose(disk_image_file);
        return 1;
    }

    // Make sure that the bootloader file is exactly 32768 bytes long.
    fseek(bootloader_file, 0, SEEK_END);
    int bootloader_size = ftell(bootloader_file);
    fseek(bootloader_file, 0, SEEK_SET);
    if (bootloader_size != BOOTLOADER_SIZE) {
        fprintf(stderr, "error: bootloader is not exactly %d bytes long\n", BOOTLOADER_SIZE);
        return 1;
    }

    // Preserve the original disk signature from the disk image.
    uint8_t disk_signature[DISK_SIGNATURE_SIZE];
    fseek(disk_image_file, DISK_SIGNATURE_OFFSET, SEEK_SET);
    fread(disk_signature, sizeof(uint8_t), DISK_SIGNATURE_SIZE, disk_image_file);
    fseek(disk_image_file, 0, SEEK_SET);

    // Preserve the original partition table from the disk image.
    uint8_t partition_table[PARTITION_TABLE_SIZE];
    fseek(disk_image_file, PARTITION_TABLE_OFFSET, SEEK_SET);
    fread(partition_table, sizeof(uint8_t), PARTITION_TABLE_SIZE, disk_image_file);
    fseek(disk_image_file, 0, SEEK_SET);

    // Allocate the transfer buffer.
    void* bootloader_code = malloc(BOOTLOADER_SIZE);
    if (bootloader_code == NULL) {
        fprintf(stderr, "error: failed to allocate memory for the transfer buffer");
        return 1;
    }

    // Read the bootloader code into the transfer buffer.
    fread(bootloader_code, sizeof(uint8_t), BOOTLOADER_SIZE, bootloader_file);

    // Write the transfer buffer to the image file.
    fwrite(bootloader_code, sizeof(uint8_t), BOOTLOADER_SIZE, disk_image_file);

    // Restore the original disk signature in the disk image.
    fseek(disk_image_file, DISK_SIGNATURE_OFFSET, SEEK_SET);
    fwrite(disk_signature, sizeof(uint8_t), DISK_SIGNATURE_SIZE, disk_image_file);

    // Restore the original partition table in the disk image.
    fseek(disk_image_file, PARTITION_TABLE_OFFSET, SEEK_SET);
    fwrite(partition_table, sizeof(uint8_t), PARTITION_TABLE_SIZE, disk_image_file);

    fclose(disk_image_file);
    fclose(bootloader_file);

    return 0;
}
