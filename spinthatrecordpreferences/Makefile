include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpinThatRecordPreferences
SpinThatRecordPreferences_FILES = STRPRootListController.m
SpinThatRecordPreferences_EXTRA_FRAMEWORKS += Cephei
SpinThatRecordPreferences_EXTRA_FRAMEWORKS += CepheiPrefs
SpinThatRecordPreferences_EXTRA_FRAMEWORKS += MenushkaPrefs
SpinThatRecordPreferences_INSTALL_PATH = /Library/PreferenceBundles
SpinThatRecordPreferences_FRAMEWORKS = UIKit
SpinThatRecordPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SpinThatRecordPreferences.plist$(ECHO_END)
