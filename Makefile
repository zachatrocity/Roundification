export THEOS_DEVICE_IP=192.168.0.102
ARCHS=armv7 arm64
include theos/makefiles/common.mk
export GO_EASY_ON_ME := 1

TWEAK_NAME = Roundification
Roundification_FILES = Tweak.xm
Roundification_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += roundification
include $(THEOS_MAKE_PATH)/aggregate.mk
