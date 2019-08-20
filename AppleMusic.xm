%hook MusicNowPlayingContentView
%new
-(void)test {
    HBLogDebug(@"sdfsdfasagagdsafda");
}
%end

%ctor {
	%init(MusicNowPlayingContentView=objc_getClass("Music.NowPlayingContentView"));
}