.DEFAULT_GOAL=help
SHELL=/usr/bin/env bash

export APP_ORG=com.thapaliya
$(info -- APP_ORG is set to $(APP_ORG))

export APP_ID=nepali-romanized-pro
$(info -- APP_ID is set to $(APP_ID))

export APP_PKG=install
$(info -- APP_PKG is set to $(APP_PKG))

export APP_PKG_ID=$(APP_ORG).$(APP_ID).$(APP_PKG)
$(info -- APP_PKG_ID is set to $(APP_PKG_ID))

export APP_VERSION=0.0.1
$(info -- APP_VERSION is set to $(APP_VERSION))

export BUILD_DIR=build
$(info -- BUILD_DIR is set to $(BUILD_DIR))

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
	cp -a lib/*.keylayout $(BUILD_DIR)/installpkgroot/Library/Keyboard\ Layouts/
	cp -a lib/*.icns $(BUILD_DIR)/installpkgroot/Library/Keyboard\ Layouts/
	$(info -- Building installation package)
	mkdir -p $(BUILD_DIR)/package/
	pkgbuild --identifier $(APP_PKG_ID) \
	--version $(APP_VERSION) \
	--root $(BUILD_DIR)/installpkgroot \
	$(BUILD_DIR)/package/$(APP_PKG_ID).pkg

build-product:
	$(info -- Preparing installation product directory)
	mkdir -p $(BUILD_DIR)/product/
	cp -Rv darwin $(BUILD_DIR)/_darwin
	sed -i '' -e 's/__APP_PKG_ID__/'$(APP_PKG_ID)'/g' $(BUILD_DIR)/_darwin/distribution.xml
	$(info -- Building installation product)
	productbuild --distribution $(BUILD_DIR)/_darwin/distribution.xml \
	--resources $(BUILD_DIR)/_darwin/Resources \
	--package-path $(BUILD_DIR)/package \
	$(BUILD_DIR)/product/$(APP_ID)-$(APP_VERSION).pkg
