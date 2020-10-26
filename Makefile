include make/options.mk
include make/tools.mk
include make/utils.mk

export ROOT_DIR  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export BUILD_DIR := $(ROOT_DIR)/build-$(PROFILE)
export TOOLS_DIR := $(ROOT_DIR)/build-$(PROFILE)/tools

export PATH := "$(PATH):$(ROOT_DIR)/toolchain/x86_64-elf/bin"

VERSION := 0.1.0
DISK_IMAGE := $(BUILD_DIR)/berry-os-$(VERSION).img

.PHONY: all clean \
	layer1 layer2 layer3 \
	tools disk-image bootloader \
	toolchain qemu

all: disk-image

clean:
	rm -r $(ROOT_DIR)/build-debug
	rm -r $(ROOT_DIR)/build-release

layer1: bootloader

layer2: layer1

layer3: layer2

tools:
	$(MAKE) -C $(ROOT_DIR)/tools all

disk-image: layer3 tools
	dd if=/dev/zero of=$(DISK_IMAGE) bs=1M count=32 $(SILENT)
	parted -s $(DISK_IMAGE) mklabel msdos $(SILENT)
	parted -s $(DISK_IMAGE) mkpart primary 1 100% $(SILENT)
	parted -s $(DISK_IMAGE) set 1 boot on $(SILENT)
	$(BUILD_DIR)/tools/install_bootloader $(DISK_IMAGE) $(BUILD_DIR)/bootloader/bootloader.bin

bootloader:
	$(MAKE) -C $(ROOT_DIR)/bootloader all

toolchain:
	$(ROOT_DIR)/toolchain/install.sh

qemu:
	qemu-system-x86_64 -drive format=raw,file=$(DISK_IMAGE)
