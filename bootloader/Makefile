THIS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SOURCE_FILES := $(THIS_DIR)/bootloader.asm
BINARY_FILES := $(patsubst $(ROOT_DIR)/%.asm,$(BUILD_DIR)/%.bin,$(SOURCE_FILES))

all: $(BINARY_FILES)

$(BUILD_DIR)/%.bin: $(ROOT_DIR)/%.asm FORCE
	mkdir -p $(@D)
	nasm -f bin -o $@ $<

FORCE: ;
