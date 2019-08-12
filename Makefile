include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpinTheRecord
SpinTheRecord_FILES = $(wildcard *.xm)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotify"
