.DEFAULT_GOAL=help
SHELL:=/usr/bin/env bash

APP_ORG:=com.thapaliya
APP_ID:=nepali-romanized
APP_PKG:=install

APP_PKG_ID:=$(APP_ORG).$(APP_ID).$(APP_PKG)
$(info -- APP_PKG_ID is set to $(APP_PKG_ID))

# Remember to bump the version in Info.plist as well
APP_VERSION:=4.0
$(info -- APP_VERSION is set to $(APP_VERSION))

BUILD_DIR:=build
BUILD_TIMESTAMP:=$(shell TZ=Asia/Katmandu date)

$(info -- )

.PHONY: help clean

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

clean:  ## Clean build directory
	$(info -- Cleaning build directory)
	rm -rf $(BUILD_DIR)

build: clean build-install-package build-product

build-install-package:
	$(info -- Preparing installation package directory)
	mkdir -p $(BUILD_DIR)/installpkgroot/Library/Keyboard\ Layouts/
	cp -aR lib/$(APP_ID).bundle $(BUILD_DIR)/installpkgroot/Library/Keyboard\ Layouts/
	$(info -- Building installation package)
	mkdir -p $(BUILD_DIR)/package/
	pkgbuild --identifier $(APP_PKG_ID) \
	--version $(APP_VERSION) \
	--root $(BUILD_DIR)/installpkgroot \
	--scripts pkgdeps/scripts \
	$(BUILD_DIR)/package/$(APP_PKG_ID).pkg

build-product:
	$(info -- Preparing installation product directory)
	mkdir -p $(BUILD_DIR)/product/
	cp -Rv productdeps $(BUILD_DIR)/_productdeps
	sed -i '' -e 's/__APP_VERSION__/$(APP_VERSION)/g' $(BUILD_DIR)/_productdeps/distribution.xml
	sed -i '' -e 's/__BUILD_TIMESTAMP__/$(BUILD_TIMESTAMP)/g' $(BUILD_DIR)/_productdeps/distribution.xml
	sed -i '' -e 's/__APP_PKG_ID__/$(APP_PKG_ID)/g' $(BUILD_DIR)/_productdeps/distribution.xml
	$(info -- Building installation product)
	productbuild --distribution $(BUILD_DIR)/_productdeps/distribution.xml \
	--resources $(BUILD_DIR)/_productdeps/Resources \
	--package-path $(BUILD_DIR)/package \
	$(BUILD_DIR)/product/$(APP_ID)-$(APP_VERSION).pkg
