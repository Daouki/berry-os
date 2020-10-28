export NASM ?= nasm

export OBJCOPY ?= x86_64-elf-objcopy

export NATIVE_CC := $(or $(CC),$(CC),cc)
export NATIVE_CFLAGS := -std=c99 -Wall -Wextra

export TARGET_CC := x86_64-elf-gcc
export TARGET_CFLAGS := -std=c99 -Wall -Wextra -I$(ROOT_DIR)/libstdc/include

export TARGET_LD := $(TARGET_CC)
export TARGET_LDFLAGS := -L$(LIBS_DIR)

export TARGET_AR := x86_64-elf-ar

export TARGET_CC_32BIT := i386-elf-gcc
export TARGET_LD_32BIT := $(TARGET_CC_32BIT)
export TARGET_AR_32BIT := i386-elf-ar
