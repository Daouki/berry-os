export NASM ?= nasm

export NATIVE_CC := $(or $(CC),$(CC),cc)

export NATIVE_CFLAGS := -std=c99
