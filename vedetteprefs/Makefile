TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VedettePrefs

VedettePrefs_FILES = $(wildcard *.m) $(wildcard ChoicyPreferences/*.m) ../VDTShared.mm
VedettePrefs_FRAMEWORKS = UIKit
VedettePrefs_PRIVATE_FRAMEWORKS = Preferences
VedettePrefs_EXTRA_FRAMEWORKS = AltList
VedettePrefs_INSTALL_PATH = /Library/PreferenceBundles
VedettePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
