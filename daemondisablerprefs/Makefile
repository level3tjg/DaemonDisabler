include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DaemonDisablerPrefs

DaemonDisablerPrefs_FILES = ddRootListController.m
DaemonDisablerPrefs_INSTALL_PATH = /Library/PreferenceBundles
DaemonDisablerPrefs_FRAMEWORKS = UIKit
DaemonDisablerPrefs_PRIVATE_FRAMEWORKS = Preferences
DaemonDisablerPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DaemonDisablerPrefs.plist$(ECHO_END)
