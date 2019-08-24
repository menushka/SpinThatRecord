#include "STRPRootListController.h"

@implementation STRPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self setSourceUrl:@"https://github.com/menushka/SpinThatRecord"];
		[self showSource:YES];
		[self showDonate:YES];
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

@end
