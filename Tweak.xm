#import <Cephei/HBPreferences.h>

#define SPIN_THE_RECORD_ANIMATION_KEY @"SpinThatRecordAnimation"

HBPreferences *prefs;
BOOL prefEnabled;
float prefSpinSpeed;

@interface SPTPlayerState
-(BOOL)isBuffering;
-(BOOL)isLoading;
-(BOOL)isPaused;
-(BOOL)isPlaying;
@end

@interface SPTNowPlayingCoverArtImageContentView : UIImageView
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
-(void)refreshContentCells;
@end

SPTNowPlayingContentView *contentView;
BOOL isVisible = NO;
BOOL isPlaying = NO;

%group SpinThatRecordEnabled

%hook SPTNowPlayingContentView

-(id)initWithFrame:(CGRect)arg1 viewModel:(id)arg2 imageLoaderFactory:(id)arg3 backgroundDelegate:(id)arg4 nowPlayingVideoManager:(id)arg5 {
	contentView = %orig;
	return contentView;
}

-(id)setContentCells:(id)arg1 {
	id r = %orig;
	[self refreshContentCells];
	return r;
}

%new
-(void)refreshContentCells {
	HBLogDebug(@"REFRESH CALLED");
	for (int i = 0; i < self.contentCells.count; i++) {
		if (i == 2 && isPlaying && isVisible) {
			[((SPTNowPlayingContentCell *)self.contentCells[i]).coverArtContent startRotation];
		} else {
			[((SPTNowPlayingContentCell *)self.contentCells[i]).coverArtContent stopRotation];
		}
	}
}

%end

%hook SPTNowPlayingModel

%property (nonatomic, retain) SPTNowPlayingContentView *contentView;

-(void)player:(id)arg1 stateDidChange:(id)arg2 fromState:(id)arg3 {
    %orig;
	if ([arg2 isPlaying] && ![arg2 isPaused]) {
		HBLogDebug(@"PLAYING YES");
		isPlaying = YES;
	} else {
		HBLogDebug(@"PLAYING NO");
		isPlaying = NO;
	}
	HBLogDebug(@"%@", contentView);
	[contentView refreshContentCells];
}

%end

%hook SPTNowPlayingViewController

%property (nonatomic, retain) SPTNowPlayingContentView *contentView;

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	isVisible = YES;
	[contentView refreshContentCells];
}

-(void)viewWillDisappear:(BOOL)animated {
	%orig;
	isVisible = NO;
	[contentView refreshContentCells];
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
	self.rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
	self.rotationAnimation.duration = 1.0f / prefSpinSpeed;
	self.rotationAnimation.repeatCount = INFINITY;
	self.spinning = NO;
}

%new
-(void)startRotation {
	if (self.spinning) return;
	self.spinning = YES;

	if (![self.layer animationForKey:SPIN_THE_RECORD_ANIMATION_KEY]) {
		HBLogDebug(@"SPINNING START: ADD");
		[self.layer addAnimation:self.rotationAnimation forKey:SPIN_THE_RECORD_ANIMATION_KEY];

		CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
		self.layer.speed = 0.0;
		self.layer.timeOffset = pausedTime;
	} 
	HBLogDebug(@"SPINNING START: RESUME");
	CFTimeInterval pausedTime = [self.layer timeOffset];
	self.layer.speed = 1.0;
	self.layer.timeOffset = 0.0;
	self.layer.beginTime = 0.0;
	CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	self.layer.beginTime = timeSincePause;
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

%end

void loadPrefs() {
	prefs = [[HBPreferences alloc] initWithIdentifier:@"ca.menushka.spinthatrecord.preferences"];

	prefEnabled = [prefs boolForKey:@"enabled" default:YES];
	prefSpinSpeed = [prefs floatForKey:@"spinSpeed" default:0.1];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("ca.menushka.spinthatrecord.preferences/ReloadPrefs"), NULL, kNilOptions);

	if (prefEnabled) {
		%init(SpinThatRecordEnabled);
	}
}