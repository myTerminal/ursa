SHELL = /bin/sh

ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

help:
	@echo "Use one of the following options:"
	@echo "setup - Set up ursa"
	@echo "remove - Remove ursa"
	@echo "redeploy - Re-setup ursa"

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
	@echo "xdg-utils found."
else
	@echo "xdg-utils not found!"
	@echo "Attempting to install xdg-utils using Crater..."
	/tmp/crater-cli/crater install xdg-utils
endif
ifneq ($(shell command -v udisksctl),)
	@echo "udisks2 found."
else
	@echo "udisks2 not found!"
	@echo "Attempting to install udisks2 using Crater..."
	/tmp/crater-cli/crater install udisks2
endif
ifneq ($(shell command -v startxfce4),)
	@echo "xfce4 found."
else
	@echo "xfce4 not found!"
	@echo "Attempting to install xfce4 using Crater..."
	/tmp/crater-cli/crater install xfce4
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

place:
	@echo "Installing commands..."
	sudo install ./commands/* $(PREFIX)/bin/
	@echo "Commands installed."

setup: req place
	./scripts/configure
	@echo "Setup complete!"

remove:
	@echo "Removing ursa..."
	sudo rm $(PREFIX)/bin/ursa*
	rm ~/.config/autostart/thunar.desktop
	@echo "ursa has been removed!"

redeploy: remove setup
