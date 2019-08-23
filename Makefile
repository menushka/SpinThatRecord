include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpinThatRecord
SpinThatRecord_FILES = $(wildcard *.xm) $(wildcard *.m)
SpinThatRecord_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotify Music"
SUBPROJECTS += spinthatrecordpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
