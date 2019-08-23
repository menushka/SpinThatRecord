#import "MWRecordCALayer.h"

@interface ArtworkComponentImageView : UIView
@property (nonatomic, retain) CABasicAnimation *rotationAnimation;
@property (assign) BOOL spinning;
-(void)cachedRotation;
-(void)startRotation;
-(void)stopRotation;
@end

ArtworkComponentImageView *currentArtwork;

%hook MusicNowPlayingContentView

- (void)addSubview:(UIView *)view {
	%orig;
	if ([view isKindOfClass:NSClassFromString(@"Music.ArtworkComponentImageView")]) {
		currentArtwork = (ArtworkComponentImageView *)view;
		MWRecordCALayer *layer = (MWRecordCALayer *)currentArtwork.layer;
		[layer roundLayer];
	}
}

%end

%hook ArtworkComponentImageView

-(Class)_layerClass {
    return %c(MWRecordCALayer);
}

%end

@interface MusicMiniPlayerViewController
-(id)playPauseButton;
-(void)onPlayPausePressed;
@end

%hook MusicMiniPlayerViewController

-(void)viewDidLoad {
	%orig;
	UIButton *button = [self playPauseButton];
	[button addTarget:self action:@selector(onPlayPausePressed) forControlEvents:UIControlEventTouchUpInside];
}

%new
-(void)onPlayPausePressed {
	MWRecordCALayer *layer = (MWRecordCALayer *)currentArtwork.layer;
	// if (currentArtwork.spinning) {
	// 	[layer stopRotation];
	// } else {
		[layer startRotation];
	// }
}

%end

@interface MusicNowPlayingControlsViewController
-(id)playPauseStopButton;
-(void)onPlayPauseStopPressed;
@end

%hook MusicNowPlayingControlsViewController

-(void)viewDidLoad {
	%orig;
	UIButton *button = [self playPauseStopButton];
	[button addTarget:self action:@selector(onPlayPauseStopPressed) forControlEvents:UIControlEventTouchUpInside];
}

%new
-(void)onPlayPauseStopPressed {
	MWRecordCALayer *layer = (MWRecordCALayer *)currentArtwork.layer;
	// if (currentArtwork.spinning) {
	// 	[layer stopRotation];
	// } else {
		[layer startRotation];
	// }
}

%end

%ctor {
	%init(ArtworkComponentImageView=objc_getClass("Music.ArtworkComponentImageView"), MusicNowPlayingContentView=objc_getClass("Music.NowPlayingContentView"), MusicMiniPlayerViewController=objc_getClass("Music.MiniPlayerViewController"));
}