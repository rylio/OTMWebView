//
//  OTMWebViewProgressBar.h
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

#import <UIKit/UIKit.h>
/**
 *  OTMWebViewProgressBar is a progress bar meant to mimick Mobile Safari's iOS 7 progress bar.
 */

@interface OTMWebViewProgressBar : UIView

/**
 *  Progress of progress bar. Setting this causes the progress to change without animation.
 */
@property (nonatomic) double progress;

/**
 *  Set the progress with a custom duration for the animation
 *
 *  @param progress          The new progress value. Between 0.0 and 1.0.
 *  @param animationDuration The duration of the animation in seconds.
 */
- (void)setProgress:(double)progress animationDuration:(NSTimeInterval)animationDuration;

/**
 *  Set the progress and change whether or not it is animated.
 *
 *  @param progress The new progress value. Between 0.0 and 1.0.
 *  @param animated YES the progress change should be animated with default animation duration of 0.1 seconds. NO if the change should happen immediatley.
 */
- (void)setProgress:(double)progress animated:(BOOL)animated;

/**
 *  Tint color of the progress bar. Default is [UIColor blueColor]
 */
@property (strong, nonatomic) UIColor *tintColor;

/**
 *  If YES, once the progress reaches 1.0 the progress bar should fade, and the progress be set to 0. Default is YES.
 */
@property (nonatomic) BOOL fadeOnFinish;

/**
 *  The duration of the fadeOnFinishAnimation in seconds. Default is 0.75 seconds.
 */
@property (nonatomic) NSTimeInterval fadeOnFinishAnimationDuration;

/**
 *  The amount of time after the progress has finished to initiate the fade animation. Default is 0.25 seconds.
 */
@property (nonatomic) NSTimeInterval fadeOnFinishDelay;

@end
