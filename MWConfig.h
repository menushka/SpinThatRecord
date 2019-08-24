@interface MWConfig : NSObject
@property (assign) BOOL enabled;
@property (assign) float spinSpeed;
@property (assign) float innerCutout;
+(instancetype)sharedInstance;
-(void)loadPrefs;
@end