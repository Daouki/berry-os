THIS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LOCAL_CFLAGS := $(NATIVE_CFLAGS) -g

SOURCE_FILES := $(shell find $(THIS_DIR) -name "*.c" -type f)
BINARY_FILES := $(patsubst $(ROOT_DIR)/%.c,$(BUILD_DIR)/%,$(SOURCE_FILES))
DEPEND_FILES := $(patsubst %,%.d,$(BINARY_FILES))

-include $(DEPEND_FILES)

all: $(BINARY_FILES)

$(BUILD_DIR)/%: $(ROOT_DIR)/%.c
	mkdir -p $(@D)
	$(NATIVE_CC) $(LOCAL_CFLAGS) -MMD -o $@ $<
