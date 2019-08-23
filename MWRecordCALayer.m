#import "MWRecordCALayer.h"

#define SPIN_THE_RECORD_ANIMATION_KEY @"SpinThatRecordAnimation"

@implementation MWRecordCALayer {
    CALayer *subLayer;
    BOOL spinning;
    BOOL rounded;
}

-(id)init {
    self = [super init];
    if (self) {
        subLayer = [[CALayer alloc] init];
        [self cacheRotation];
		[self cutHole];
        [self addSublayer:subLayer];
    }
    return self;
}

-(void)setContents:(id)arg1 {
    subLayer.contents = arg1;
}

-(void)setFrame:(CGRect)arg1 {
    [super setFrame:arg1];
    [subLayer setFrame:CGRectMake(-arg1.size.width / 2, -arg1.size.height / 2, arg1.size.width, arg1.size.height)];
	[self cutHole];
}

-(void)setBounds:(CGRect)arg1 {
    [super setBounds:CGRectMake(-arg1.size.width / 2, -arg1.size.height / 2, arg1.size.width, arg1.size.height)];
    [subLayer setBounds:CGRectMake(-arg1.size.width / 2, -arg1.size.height / 2, arg1.size.width, arg1.size.height)];
	[self cutHole];
}

-(void)setCornerRadius:(CGFloat)arg1 {
    if (rounded) {
        [subLayer setCornerRadius:self.bounds.size.height / 2];
    } else {
        [subLayer setCornerRadius:arg1];
    }
}

-(void)setMasksToBounds:(BOOL)arg1 {
    [subLayer setMasksToBounds:YES];
}

-(void)setBorderWidth:(CGFloat)arg1 {
    [subLayer setBorderWidth:0];
}

-(void)roundLayer {
    rounded = YES;
    [self setCornerRadius:0];
}

-(void)cutHole {
	if (!rounded) return;

	float diameter = self.bounds.size.width;
	float radius = self.bounds.size.height / 2;
	float innerSize = diameter * 0.125f;
	UIBezierPath *outerCircle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-diameter / 2, -diameter / 2, diameter, diameter) cornerRadius:radius];
	UIBezierPath *innerCircle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0 - innerSize / 2, 0 - innerSize / 2, innerSize, innerSize) cornerRadius:innerSize / 2];
	[outerCircle appendPath:innerCircle];

	CAShapeLayer *maskLayer = [CAShapeLayer new];
	maskLayer.fillRule = kCAFillRuleEvenOdd;
	maskLayer.path = outerCircle.CGPath;
	subLayer.mask = maskLayer;
}

-(void)cacheRotation {
	self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	self.rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
	self.rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
	self.rotationAnimation.duration = 1.0f / 0.1;
	self.rotationAnimation.repeatCount = INFINITY;
}

-(void)startRotation {
	if (spinning) return;
	spinning = YES;

	if (![subLayer animationForKey:SPIN_THE_RECORD_ANIMATION_KEY]) {
		HBLogDebug(@"SPINNING START: ADD");
		HBLogDebug(@"%@", SPIN_THE_RECORD_ANIMATION_KEY);
		HBLogDebug(@"%@", self.rotationAnimation);
		[subLayer addAnimation:self.rotationAnimation forKey:SPIN_THE_RECORD_ANIMATION_KEY];

		CFTimeInterval pausedTime = [subLayer convertTime:CACurrentMediaTime() fromLayer:nil];
		subLayer.speed = 0.0;
		subLayer.timeOffset = pausedTime;
	} 
	HBLogDebug(@"SPINNING START: RESUME");
	CFTimeInterval pausedTime = [subLayer timeOffset];
	subLayer.speed = 1.0;
	subLayer.timeOffset = 0.0;
	subLayer.beginTime = 0.0;
	CFTimeInterval timeSincePause = [subLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	subLayer.beginTime = timeSincePause;
}

-(void)stopRotation {
	if (!spinning) return;
	spinning = NO;

	HBLogDebug(@"SPINNING STOP");
	CFTimeInterval pausedTime = [subLayer convertTime:CACurrentMediaTime() fromLayer:nil];
	subLayer.speed = 0.0;
	subLayer.timeOffset = pausedTime;
}

@end