THIS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
THIS_BUILD_DIR := $(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%,$(THIS_DIR))
THIS_BUILD_DIR_32BIT := $(THIS_BUILD_DIR)/libstdc32
THIS_BUILD_DIR_64BIT := $(THIS_BUILD_DIR)/libstdc64

LOCAL_CFLAGS := -ffreestanding -I$(THIS_DIR)/include

SOURCE_FILES       := $(shell find $(THIS_DIR)/src -type f -name "*.c")
OBJECT_FILES_32BIT := $(patsubst $(THIS_DIR)/%,$(THIS_BUILD_DIR_32BIT)/%.o,$(SOURCE_FILES))
OBJECT_FILES_64BIT := $(patsubst $(THIS_DIR)/%,$(THIS_BUILD_DIR_64BIT)/%.o,$(SOURCE_FILES))
DEPEND_FILES_32BIT := $(patsubst $(THIS_DIR)/%,$(THIS_BUILD_DIR_32BIT)/%.d,$(SOURCE_FILES))
DEPEND_FILES_64BIT := $(patsubst $(THIS_DIR)/%,$(THIS_BUILD_DIR_64BIT)/%.d,$(SOURCE_FILES))

-include $(DEPEND_FILES)

all: $(THIS_BUILD_DIR)/libstdc.a $(THIS_BUILD_DIR)/libstdc32.a
	mkdir -p $(LIBS_DIR)
	cp $(THIS_BUILD_DIR)/libstdc.a $(LIBS_DIR)
	cp $(THIS_BUILD_DIR)/libstdc32.a $(LIBS_DIR)

# 64-bit version of the libstdc

$(THIS_BUILD_DIR)/libstdc.a: $(OBJECT_FILES_64BIT)
	$(TARGET_AR) rcs $@ $(OBJECT_FILES_64BIT)

$(THIS_BUILD_DIR_64BIT)/%.o: $(THIS_DIR)/%
	mkdir -p $(@D)
	$(TARGET_CC) $(TARGET_CFLAGS) $(LOCAL_CFLAGS) -MMD -c -o $@ $<

# 32-bit version of the libstdc

$(THIS_BUILD_DIR)/libstdc32.a: $(OBJECT_FILES_32BIT)
	$(TARGET_AR_32BIT) rcs $@ $(OBJECT_FILES_32BIT)

$(THIS_BUILD_DIR_32BIT)/%.o: $(THIS_DIR)/%
	mkdir -p $(@D)
	$(TARGET_CC_32BIT) $(TARGET_CFLAGS) $(LOCAL_CFLAGS) -MMD -c -o $@ $<
