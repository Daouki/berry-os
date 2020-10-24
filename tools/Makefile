THIS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LOCAL_CFLAGS := $(NATIVE_CFLAGS) -g

SOURCE_FILES := $(shell find $(THIS_DIR) -name "*.c" -type f)
BINARY_FILES := $(patsubst $(ROOT_DIR)/%.c,$(BUILD_DIR)/%,$(SOURCE_FILES))

all: $(BINARY_FILES)

$(BUILD_DIR)/%: $(ROOT_DIR)/%.c FORCE
	mkdir -p $(@D)
	$(NATIVE_CC) $(LOCAL_CFLAGS) -o $@ $<

FORCE: ;
