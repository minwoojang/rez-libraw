
SHELL := /bin/bash

# Rez variables, setting these to sensible values if we are not building from rez
REZ_BUILD_PROJECT_VERSION ?= NOT_SET
REZ_BUILD_INSTALL_PATH ?= /home/minwoo/packages
REZ_BUILD_SOURCE_PATH ?= $(shell dirname $(lastword $(abspath $(MAKEFILE_LIST))))
BUILD_ROOT := $(REZ_BUILD_SOURCE_PATH)/build
REZ_BUILD_PATH ?= $(BUILD_ROOT)
REZ_JPEGTURBO_ROOT ?= /cocoa/inhouse/tool/rez-packages/jpeg/3.0.4/platform-linux/arch-x86_64

# Source
#VERSION ?= $(REZ_BUILD_PROJECT_VERSION)
#ARCHIVE_URL := https://www.libraw.org/data/LibRaw-$(VERSION).tar.gz
#LOCAL_ARCHIVE := $(BUILD_ROOT)/LibRaw.$(VERSION).tar.gz

# Source
TAG ?= $(REZ_BUILD_PROJECT_VERSION)
REPOSITORY_URL := https://github.com/LibRaw/LibRaw.git

# ifneq (,$(findstring master,$(TAG)))
# TAG:=0.21.3
# $(warning "Building master branch as TAG contains master")
# else
# Warn about building master if no tag is provided
# ifeq "$(TAG)" "NOT_SET"
# $(warning "No tag was specified, main will be built. You can specify a tag: TAG=v2.1.1")
# 
# endif
# endif
TAG:=master
# Build time locations
BUILD_TYPE = Release
BUILD_DIR = ${REZ_BUILD_PATH}/BUILD/$(BUILD_TYPE)
SOURCE_DIR := $(BUILD_DIR)/LibRaw

# Installation prefix
PREFIX ?= ${REZ_BUILD_INSTALL_PATH}

JPEG_ROOT ?= $(REZ_JPEGTURBO_ROOT)

.PHONY: build install test clean
.DEFAULT_GOAL := build

clean:
	rm -rf $(BUILD_ROOT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(SOURCE_DIR): | $(BUILD_DIR) # Clone Repository
	cd $(BUILD_DIR) && git clone $(REPOSITORY_URL)

build: $(SOURCE_DIR) # configure and build
ifeq "$(TAG)" "NOT_SET"
	$(warn "No version was specified, provide one with: VERSION=0.20.2")
else
	cd $(SOURCE_DIR)  && git checkout $(TAG) && git pull \
	&& autoreconf --install \
	&& CPPFLAGS="-I$(JPEG_ROOT)/include" LDFLAGS="-L$(JPEG_ROOT)/lib64" \
	./configure --prefix=$(PREFIX) && make
endif

install: build
	mkdir -p $(PREFIX)
	cd $(SOURCE_DIR) && make install

test: build # Run the tests in the build
	$(MAKE) -C $(BUILD_DIR) test
