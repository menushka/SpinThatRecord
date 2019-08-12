#define SPIN_THE_RECORD_ANIMATION_KEY @"SpinTheRecordAnimation"

@interface SPTPlayerState
-(BOOL)isBuffering;
-(BOOL)isLoading;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end

@interface SPTNowPlayingCoverArtImageContentView : UIImageView {
	id _storage;
}
@property (nonatomic, retain) CABasicAnimation *rotationAnimation;
@property (assign) BOOL spinning;
-(void)cachedRotation;
-(void)startRotation;
-(void)stopRotation;
@end;

@interface SPTNowPlayingContentCell : NSObject
@property (nonatomic, retain) SPTNowPlayingCoverArtImageContentView *coverArtContent;
@end

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

BOOL isPlaying = NO;

%hook SPTNowPlayingContentView

-(id)setContentCells:(id)arg1 {
	id r = %orig;

	for (int i = 0; i < self.contentCells.count; i++) {
		if (i == 2 && isPlaying) {
			[((SPTNowPlayingContentCell *)self.contentCells[i]).coverArtContent startRotation];
		} else {
			[((SPTNowPlayingContentCell *)self.contentCells[i]).coverArtContent stopRotation];
		}
	}

	return r;
}

%end

%hook SPTNowPlayingModel

-(void)player:(id)arg1 stateDidChange:(id)arg2 fromState:(id)arg3 {
    %orig;
	if ([arg2 isPlaying] && ![arg2 isPaused]) {
		HBLogDebug(@"PLAYING YES");
		isPlaying = YES;
	} else {
		HBLogDebug(@"PLAYING NO");
		isPlaying = NO;
	}
}

%end

%hook SPTNowPlayingViewController

%property (nonatomic, retain) SPTNowPlayingContentView *contentView;

-(void)viewWillAppear:(BOOL)animated {
	%log;
	%orig;
	[self getCoverArtImageView];
}

-(void)viewDidAppear:(BOOL)animated {
	%log;
	%orig;
	HBLogDebug(@"%@", isPlaying ? @"YES" : @"NO");
	if (self.contentView) {
		if (isPlaying) {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent startRotation];
		} else {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent stopRotation];
		}
	}
}

-(void)player:(id)arg1 stateDidChange:(SPTPlayerState *)arg2 fromState:(SPTPlayerState *)arg3 {
	%orig;
	if (self.contentView) {
		if (isPlaying) {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent startRotation];
		} else {
			[((SPTNowPlayingContentCell *)self.contentView.contentCells[2]).coverArtContent stopRotation];
		}
	}
}

%new
-(void)getCoverArtImageView {
	SPTNowPlayingDefaultContentViewController *defaultViewController = self.contentViewController;
	self.contentView = defaultViewController.contentView;
}

%end

%hook SPTNowPlayingContentCell

-(void)layoutSubviews {
	%orig;
	self.coverArtContent.layer.cornerRadius = self.coverArtContent.frame.size.height / 2;
	self.coverArtContent.layer.masksToBounds = YES;
	self.coverArtContent.layer.borderWidth = 0;
}

%end

%hook SPTNowPlayingCoverArtImageContentView

%property (nonatomic, retain) CABasicAnimation *rotationAnimation;
%property (assign) BOOL spinning;

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
	self.rotationAnimation.cumulative = YES;
	self.spinning = NO;
}

%new
-(void)startRotation {
	if (self.spinning) return;
	self.spinning = YES;

	HBLogDebug(@"SPINNING START");
	if (![self.layer animationForKey:SPIN_THE_RECORD_ANIMATION_KEY]) {
		[self.layer addAnimation:self.rotationAnimation forKey:SPIN_THE_RECORD_ANIMATION_KEY];
	} else {
		CFTimeInterval pausedTime = [self.layer timeOffset];
		self.layer.speed = 1.0;
		self.layer.timeOffset = 0.0;
		self.layer.beginTime = 0.0;
		CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
		self.layer.beginTime = timeSincePause;
	}
}

%new
-(void)stopRotation {
	if (!self.spinning) return;
	self.spinning = NO;

	HBLogDebug(@"SPINNING STOP");
	CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
	self.layer.speed = 0.0;
	self.layer.timeOffset = pausedTime;
}

%end