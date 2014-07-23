//
//  OTMWebViewProgressBarLayer.m
//  Pods
//
//  Created by Ryan on 7/22/14.
//
//

#import "OTMWebViewProgressBarLayer.h"

@implementation OTMWebViewProgressBarLayer
@synthesize progress;

+(BOOL)needsDisplayForKey:(NSString *)key {
	
	if ([key isEqualToString:@"progress"]) {
		
		return YES;
	}
	
	return [super needsDisplayForKey:key];
}

-(instancetype)initWithLayer:(id)layer{
	
	self = [super initWithLayer:layer];
	
	if (self) {
		
		if ([layer isKindOfClass:[OTMWebViewProgressBarLayer class]]) {
			self.progress = ((OTMWebViewProgressBarLayer *)layer).progress;
			self.tintColor = ((OTMWebViewProgressBarLayer *)layer).tintColor;

		}else {
			self.progress = 0.0;
			self.tintColor = nil;
		}
		
		self.needsDisplayOnBoundsChange = YES;
	}
	
	return self;
}

-(void)drawInContext:(CGContextRef)ctx {
	
	CGContextSaveGState(ctx);
	
	CGContextSetFillColorWithColor(ctx, (self.tintColor ?: [UIColor blueColor]).CGColor);
	
	CGRect fillRect = self.bounds;
	fillRect.size.width *= MIN(1.0, self.progress);
	
	CGContextFillRect(ctx, fillRect);
	
	CGContextRestoreGState(ctx);	
}

-(void)setTintColor:(UIColor *)tintColor {
	
	_tintColor = tintColor;
	
	[self setNeedsDisplay];
}
/*
-(id<CAAction>)actionForKey:(NSString *)event {
	
	if ([event isEqualToString:@"progress"]) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
		animation.fromValue = [self.presentationLayer valueForKey:event];
		animation.duration = 5.0;
		return animation;
	}
	
	return [super actionForKey:event];
}
*/
@end
