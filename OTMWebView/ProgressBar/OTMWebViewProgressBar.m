//
//  OTMWebViewProgressBar.m
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

#import "OTMWebViewProgressBar.h"
#import "OTMWebViewProgressBarLayer.h"

@interface OTMWebViewProgressBar ()
@property (strong, nonatomic) OTMWebViewProgressBarLayer *progressBarLayer;
@end

@implementation OTMWebViewProgressBar

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.progressBarLayer = [[OTMWebViewProgressBarLayer alloc]init];
		[self.layer addSublayer:self.progressBarLayer];
		self.progress = 0.0;
		self.fadeOnFinish = YES;
		self.fadeOnFinishAnimationDuration = 0.75;
		self.fadeOnFinishDelay = 0.25;
	}
	return self;
}

- (void)layoutSubviews
{
	self.progressBarLayer.frame = self.bounds;
}

- (void)setProgress:(double)progress
{
	[self setProgress:progress animated:NO];
}

- (double)progress
{
	return self.progressBarLayer.progress;
}

- (void)setProgress:(double)progress animated:(BOOL)animated
{
	[self setProgress:progress animationDuration:animated ? 0.1:0.0];
}

- (void)setProgress:(double)progress animationDuration:(NSTimeInterval)animationDuration
{
	if (animationDuration > 0.0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
		animation.fromValue = @(((OTMWebViewProgressBarLayer *)self.progressBarLayer.presentationLayer).progress);
		animation.toValue = @(progress);
		animation.duration = animationDuration;
		[self.progressBarLayer addAnimation:animation forKey:nil];
	}
	else {
		[self.progressBarLayer setNeedsDisplay];
	}

	self.progressBarLayer.progress = progress;

	[self.progressBarLayer removeAnimationForKey:@"fadeAnimation"];

	if (progress >= 1.0 && self.fadeOnFinish) {
		CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"alpha"];
		fadeAnimation.duration = self.fadeOnFinishAnimationDuration;
		fadeAnimation.beginTime = [self.progressBarLayer convertTime:CACurrentMediaTime() fromLayer:nil] + self.fadeOnFinishDelay;
		fadeAnimation.delegate = self;
		fadeAnimation.removedOnCompletion = NO;
		[self.progressBarLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if (anim == [self.progressBarLayer animationForKey:@"fadeAnimation"]) {
		if (flag) {
			self.progress = 0.0;
		}

		[self.progressBarLayer removeAnimationForKey:@"fadeAnimation"];
	}
}

- (void)setTintColor:(UIColor *)tintColor
{
	self.progressBarLayer.tintColor = tintColor;
}

- (UIColor *)tintColor
{
	return self.progressBarLayer.tintColor;
}

@end
