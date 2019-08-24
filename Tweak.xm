#import "MWConfig.h"

void loadPrefs() {
    [[MWConfig sharedInstance] loadPrefs];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("ca.menushka.spinthatrecord.preferences/ReloadPrefs"), NULL, kNilOptions);
}