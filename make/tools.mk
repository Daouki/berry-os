export NASM ?= nasm

export OBJCOPY ?= x86_64-elf-objcopy

export NATIVE_CC := $(or $(CC),$(CC),cc)
export NATIVE_CFLAGS := -std=c99 -Wall -Wextra

export TARGET_CC := x86_64-elf-gcc
export TARGET_CFLAGS := -std=c99 -Wall -Wextra
