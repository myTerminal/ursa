SHELL = /bin/sh

help:
	@echo "Use one of the following options:"
	@echo "setup - Set up ursa"

crater-get:
	@echo "Setting up Crater for temporary use..."
	git clone https://github.com/crater-space/cli /tmp/crater-cli

deps:
	@echo "Making sure cryptsetup is installed..."
ifneq ($(shell command -v cryptsetup),)
	@echo "cryptsetup found."
else
	@echo "cryptsetup not found!"
	@echo "Attempting to install cryptsetup using Crater..."
	/tmp/crater-cli/crater install cryptsetup
endif
ifneq ($(shell command -v xdg-open),)
	@echo "xfg-utils found."
else
	@echo "xfg-utils not found!"
	@echo "Attempting to install xfg-utils using Crater..."
	/tmp/crater-cli/crater install xfg-utils
endif
ifneq ($(shell command -v udisksctl),)
	@echo "udisks2 found."
else
	@echo "udisks2 not found!"
	@echo "Attempting to install udisks2 using Crater..."
	/tmp/crater-cli/crater install udisks2
endif
ifneq ($(shell command -v meld),)
	@echo "meld found."
else
	@echo "meld not found!"
	@echo "Attempting to install meld using Crater..."
	/tmp/crater-cli/crater install meld
endif
	@echo "All required dependencies found."

crater-remove:
	@echo "Removing Crater..."
	rm -rf /tmp/crater-cli

req: crater-get deps crater-remove

setup: req
	./ursa-deploy
