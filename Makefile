THEOS_DEVICE_IP = 192.168.1.65

ARCHS = armv7 arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DaemonDisabler

DaemonDisabler_FILES = Tweak.x
DaemonDisabler_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += daemondisablerprefs
SUBPROJECTS += launchctl_wrapper
include $(THEOS_MAKE_PATH)/aggregate.mk
