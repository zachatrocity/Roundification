ARCHS = armv7 arm64 
include theos/makefiles/common.mk

ADDITIONAL_CFLAGS = -fobjc-arc
BUNDLE_NAME = Roundification
Roundification_FILES = Roundification.mm BetterPSSliderTableCell.mm
Roundification_INSTALL_PATH = /Library/PreferenceBundles
Roundification_FRAMEWORKS = UIKit
Roundification_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Roundification.plist$(ECHO_END)
