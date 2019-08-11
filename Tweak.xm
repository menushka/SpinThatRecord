#define SPIN_THE_RECORD_ANIMATION_KEY @"SpinTheRecordAnimation"

@interface SPTPlayerState
-(BOOL)isBuffering;
-(BOOL)isLoading;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end

@interface SPTNowPlayingCoverArtImageContentView : UIImageView
@property (nonatomic, retain) CABasicAnimation *rotationAnimation;
-(void)cachedRotation;
-(void)startRotation;
-(void)stopRotation;
@end;

@interface SPTNowPlayingContentCell : NSObject
@property (nonatomic, retain) SPTNowPlayingCoverArtImageContentView *coverArtContent;
@end

%hook SPTNowPlayingContentCell

- (void)layoutSubviews {
	%orig;
	// HBLogDebug(@"----------------------------------------------- Properties for object %@", self);

    // @autoreleasepool {
    //     unsigned int numberOfProperties = 0;
    //     objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    //     for (NSUInteger i = 0; i < numberOfProperties; i++) {
    //         objc_property_t property = propertyArray[i];
    //         NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
    //         HBLogDebug(@"Property %@ Value: %@", name, [self valueForKey:name]);
    //     }
    //     free(propertyArray);
    // }    
    // HBLogDebug(@"-----------------------------------------------");
}
%end

@interface SPTNowPlayingContentView
@property (nonatomic, retain) NSMutableArray *contentCells;
@end

@interface SPTNowPlayingDefaultContentViewController
@property (nonatomic, retain) SPTNowPlayingContentView *contentView;
@end

@interface SPTNowPlayingViewController : UIViewController
@property (nonatomic, retain) SPTNowPlayingContentView *contentView;
@property (nonatomic, retain) SPTNowPlayingDefaultContentViewController *contentViewController;
-(void)getCoverArtImageView;
@end

%hook SPTNowPlayingViewController

%property (nonatomic, retain) SPTNowPlayingContentView *contentView;

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	[self getCoverArtImageView];
}

-(void)player:(id)arg1 stateDidChange:(SPTPlayerState *)arg2 fromState:(SPTPlayerState *)arg3 {
	if (self.contentView) {
		if ([arg3 isPaused]) {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent stopRotation];
		} else {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent startRotation];
		}
	}
	return %orig;
}

%new
-(void)getCoverArtImageView {
	SPTNowPlayingDefaultContentViewController *defaultViewController = self.contentViewController;
	self.contentView = defaultViewController.contentView;
}

%end

%hook SPTNowPlayingCoverArtImageContentView

%property (nonatomic, retain) CABasicAnimation *rotationAnimation;

-(id)initWithFrame:(CGRect)arg1 {
	SPTNowPlayingCoverArtImageContentView *r = %orig;
	[r cachedRotation];
	return r;
}

-(id)initWithCoder:(id)arg1 {
	SPTNowPlayingCoverArtImageContentView *r = %orig;
	[r cachedRotation];
	return r;
}

-(id)initWithImage:(id)arg1 {
	SPTNowPlayingCoverArtImageContentView *r = %orig;
	[r cachedRotation];
	return r;
}

-(id)initWithImage:(id)arg1 highlightedImage:(id)arg2 {
	SPTNowPlayingCoverArtImageContentView *r = %orig;
	[r cachedRotation];
	return r;
}

%new
-(void)cachedRotation {
	self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	self.rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
	self.rotationAnimation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
	self.rotationAnimation.duration = 10.0f;
	self.rotationAnimation.repeatCount = INFINITY;
}

%new
-(void)startRotation {
	[self.layer addAnimation:self.rotationAnimation forKey:SPIN_THE_RECORD_ANIMATION_KEY];
}

%new
-(void)stopRotation {
	[self.layer removeAnimationForKey:SPIN_THE_RECORD_ANIMATION_KEY];
}

%end