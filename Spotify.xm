#import <Cephei/HBPreferences.h>
#import "MWConfig.h"
#import "MWRecordCALayer.h"

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
		SPTNowPlayingCoverArtImageContentView *coverArtContent = ((SPTNowPlayingContentCell *)self.contentCells[i]).coverArtContent;
		MWRecordCALayer *layer = (MWRecordCALayer *)coverArtContent.layer;
		if (i == 2 && isPlaying && isVisible) {
			[layer startRotation];
		} else {
			[layer stopRotation];
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
	MWRecordCALayer *layer = (MWRecordCALayer *)self.coverArtContent.layer;
	[layer roundLayer];
}

%end

%hook SPTNowPlayingCoverArtImageContentView

-(Class)_layerClass {
    return %c(MWRecordCALayer);
}

%end

%hook SPTNowPlayingCoverArtImageView

-(Class)_layerClass {
    return %c(MWRecordCALayer);
}

%end

%hook SpotifyAppDelegate

%new
- (void)applicationWillEnterForeground:(UIApplication *)application {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[contentView refreshContentCells];
	});
}

%end

%end

%ctor {
	HBLogDebug(@"SPOTIFY");
	if ([MWConfig sharedInstance].enabled) {
		%init(SpinThatRecordEnabled);
	}
}