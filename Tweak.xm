#import "MWConfig.h"

void loadPrefs() {
    [[MWConfig sharedInstance] loadPrefs];
}

%ctor {
	HBLogDebug(@"TWEAK");
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("ca.menushka.spinthatrecord.preferences/ReloadPrefs"), NULL, kNilOptions);
}