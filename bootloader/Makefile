THIS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
THIS_BUILD_DIR := $(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%,$(THIS_DIR))

LOCAL_CFLAGS := -ffreestanding -fno-builtin
LOCAL_LDFLAGS := -nostdlib

STAGE1_SOURCE_FILE := $(THIS_DIR)/stage1.asm
STAGE1_BINARY_FILE := $(patsubst $(ROOT_DIR)/%.asm,$(BUILD_DIR)/%.bin,$(STAGE1_SOURCE_FILE))

STAGE2_SOURCE_FILES := $(shell find "$(THIS_DIR)/stage2" -type f -name *.asm)
STAGE2_SOURCE_FILES += $(shell find "$(THIS_DIR)/stage2" -type f -name *.c)
STAGE2_OBJECT_FILES := $(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%.o,$(STAGE2_SOURCE_FILES))
STAGE2_OUTPUT_FILE  := $(THIS_BUILD_DIR)/stage2.elf
STAGE2_BINARY_FILE  := $(THIS_BUILD_DIR)/stage2.bin

all: $(STAGE1_BINARY_FILE) $(STAGE2_BINARY_FILE) FORCE
	dd if=/dev/zero of=$(THIS_BUILD_DIR)/bootloader.bin bs=512 count=64 $(SILENT)
	dd if=$(STAGE1_BINARY_FILE) of=$(THIS_BUILD_DIR)/bootloader.bin bs=512 seek=0 conv=notrunc $(SILENT)
	dd if=$(STAGE2_BINARY_FILE) of=$(THIS_BUILD_DIR)/bootloader.bin bs=512 seek=1 conv=notrunc $(SILENT)

$(STAGE1_BINARY_FILE): $(STAGE1_SOURCE_FILE) FORCE
	mkdir -p $(@D)
	nasm -f bin -o $@ $<

$(STAGE2_BINARY_FILE): $(STAGE2_OUTPUT_FILE) FORCE
	$(OBJCOPY) -O binary $< $@

$(STAGE2_OUTPUT_FILE): $(STAGE2_OBJECT_FILES) FORCE
	$(TARGET_LD_32BIT) $(TARGET_LDFLAGS) $(LOCAL_LDFLAGS) -T stage2.ld -o $@ $(STAGE2_OBJECT_FILES) -lstdc32

$(BUILD_DIR)/%.asm.o: $(ROOT_DIR)/%.asm FORCE
	mkdir -p $(@D)
	$(NASM) -f elf32 -o $@ $<

$(BUILD_DIR)/%.c.o: $(ROOT_DIR)/%.c FORCE
	mkdir -p $(@D)
	$(TARGET_CC_32BIT) $(TARGET_CFLAGS) $(LOCAL_CFLAGS) -c -o $@ $<

FORCE: ;
