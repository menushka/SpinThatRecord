#import <Cephei/HBPreferences.h>
#import "MWConfig.h"

#define PREF_KEY @"ca.menushka.spinthatrecord.preferences"

@implementation MWConfig

+(instancetype)sharedInstance {
    static MWConfig *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[self alloc] init];
    });
    return mySharedInstance;
}

-(void)loadPrefs {
    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREF_KEY];

	self.enabled = [prefs boolForKey:@"enabled" default:YES];
	self.spinSpeed = [prefs floatForKey:@"spinSpeed" default:0.1];
	self.innerCutout = [prefs floatForKey:@"innerCutout" default:0.125];
}

@end