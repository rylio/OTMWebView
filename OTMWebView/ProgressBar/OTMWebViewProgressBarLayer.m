//
//  OTMWebViewProgressBarLayer.m
//
// Copyright (c) 2014 Ryan Coffman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OTMWebViewProgressBarLayer.h"

@implementation OTMWebViewProgressBarLayer
@synthesize progress;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
	if ([key isEqualToString:@"progress"]) {
		return YES;
	}

	return [super needsDisplayForKey:key];
}

- (instancetype)initWithLayer:(id)layer
{
	self = [super initWithLayer:layer];

	if (self) {
		if ([layer isKindOfClass:[OTMWebViewProgressBarLayer class]]) {
			self.progress = ((OTMWebViewProgressBarLayer *)layer).progress;
			self.tintColor = ((OTMWebViewProgressBarLayer *)layer).tintColor;
		}
		else {
			self.progress = 0.0;
			self.tintColor = nil;
		}

		self.needsDisplayOnBoundsChange = YES;
	}

	return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
	CGContextSaveGState(ctx);

	CGContextSetFillColorWithColor(ctx, (self.tintColor ? : [UIColor blueColor]).CGColor);

	CGRect fillRect = self.bounds;
	fillRect.size.width *= MIN(1.0, self.progress);

	CGContextFillRect(ctx, fillRect);

	CGContextRestoreGState(ctx);
}

- (void)setTintColor:(UIColor *)tintColor
{
	_tintColor = tintColor;

	[self setNeedsDisplay];
}

@end
