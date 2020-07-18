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

.PHONY: help clean buil build-install-package build-productd

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

clean:  ## Clean build directory
	$(info -- Cleaning build directory)
	rm -rf $(BUILD_DIR)

build: clean build-install-package build-product ## Build the final product

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

icon: ## Build the icns from the input PNG file
	$(info -- Building icns file from original png)
	mkdir -p /tmp/np-icon-tmpdir.iconset
	cp assets/original/ne.png /tmp/np-icon-tmpdir.iconset/icon.png
	sips -z 16 16     /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_16x16.png
	sips -z 32 32     /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_16x16@2x.png
	sips -z 32 32     /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_32x32.png
	sips -z 64 64     /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_32x32@2x.png
	sips -z 64 64     /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_64x64.png
	sips -z 128 128   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_64x64@2x.png
	sips -z 128 128   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_128x128.png
	sips -z 256 256   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_128x128@2x.png
	sips -z 256 256   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_256x256.png
	sips -z 512 512   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_256x256@2x.png
	sips -z 512 512   /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_512x512.png
	sips -z 1024 1024 /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_512x512@2x.png
	sips -z 1024 1024 /tmp/np-icon-tmpdir.iconset/icon.png --out /tmp/np-icon-tmpdir.iconset/icon_1024x1024.png
	rm /tmp/np-icon-tmpdir.iconset/icon.png
	iconutil -c icns /tmp/np-icon-tmpdir.iconset
	mv /tmp/np-icon-tmpdir.icns assets/ne.icns
	rm -rf /tmp/np-icon-tmpdir.iconset
