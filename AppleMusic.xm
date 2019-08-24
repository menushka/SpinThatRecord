#import "MWConfig.h"
#import "MWRecordCALayer.h"

@interface ArtworkComponentImageView : UIView
@property (nonatomic, retain) CABasicAnimation *rotationAnimation;
@property (assign) BOOL spinning;
-(void)cachedRotation;
-(void)startRotation;
-(void)stopRotation;
@end

@interface MPAVController
@end

MPAVController *mpAVController;
ArtworkComponentImageView *currentArtwork;

%group SpinThatRecordEnabled

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

%hook MPAVController

-(id)init {
	mpAVController = %orig;
	return mpAVController;
}

-(BOOL)isPlaying {
	BOOL playing = %orig;
	MWRecordCALayer *layer = (MWRecordCALayer *)currentArtwork.layer;
	if (playing) {
		[layer startRotation];
	} else {
		[layer stopRotation];
	}
	return playing;
}

%end

%end

%ctor {
	if ([MWConfig sharedInstance].enabled) {
		%init(SpinThatRecordEnabled, ArtworkComponentImageView=objc_getClass("Music.ArtworkComponentImageView"), MusicNowPlayingContentView=objc_getClass("Music.NowPlayingContentView"));
	}
}
