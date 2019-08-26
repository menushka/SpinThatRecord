@interface MWRecordCALayer : CALayer
@property (nonatomic, retain) CABasicAnimation *rotationAnimation;
-(void)roundLayer;
-(void)startRotation;
-(void)stopRotation;
@end
