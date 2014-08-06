//
// OTMWebViewProgressTracker.m
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

#import "OTMWebViewProgressTracker.h"

const NSInteger kOTMWebViewProgressTrackerItemDefaultEstimatedLength = 16 * 1024;
const double kOTMWebViewProgressTrackerMaxProgressValue = 0.9;
const double kOTMWebViewProgressTrackerInitialProgressValue = 0.1;

@interface OTMWebViewProgressTrackerItem : NSObject
@property (nonatomic) long long estimatedLength;
@property (nonatomic) long long bytesReceived;
@property (nonatomic) BOOL isHTML;
@end

@implementation OTMWebViewProgressTrackerItem

- (instancetype)init
{
	self = [super init];

	if (self) {
		self.estimatedLength = 0;
		self.bytesReceived = 0;
		self.isHTML = NO;
	}

	return self;
}

@end

@interface OTMWebViewProgressTracker ()
@property (strong, nonatomic) NSMapTable *progressItems;
@property (nonatomic) long long totalBytesToLoad;
@property (nonatomic) long long totalBytesReceived;
@property (nonatomic) double progress;
@property (nonatomic) BOOL isTrackingProgress;
@property (strong, nonatomic) NSLock *lock;
@end

@implementation OTMWebViewProgressTracker

- (instancetype)init
{
	self = [super init];

	if (self) {
		self.progressItems = [NSMapTable strongToStrongObjectsMapTable];
		self.isTrackingProgress = NO;
		self.lock = [[NSLock alloc]init];
	}

	return self;
}

- (void)reset
{
	[self.progressItems removeAllObjects];
	self.totalBytesReceived = 0;
	self.totalBytesToLoad = 0;
	self.progress = 0.0;
}

- (void)setProgress:(double)progress
{
	_progress = progress;

	if (self.isTrackingProgress && [self.delegate respondsToSelector:@selector(progressTracker:progressDidChange:)]) {
		[self.delegate progressTracker:self progressDidChange:_progress];
	}
}

- (void)startProgress
{
	[self.lock lock];

	[self reset];

	self.isTrackingProgress = YES;

	if ([self.delegate respondsToSelector:@selector(progressTrackerProgressDidStart:)]) {
		[self.delegate progressTrackerProgressDidStart:self];
	}

	self.progress = kOTMWebViewProgressTrackerInitialProgressValue;

	[self.lock unlock];
}

- (void)finishProgress
{
	[self.lock lock];

	self.progress = 1.0;

	if (self.isTrackingProgress) {
		self.isTrackingProgress = NO;

		if ([self.delegate respondsToSelector:@selector(progressTrackerProgressDidFinish:)]) {
			[self.delegate progressTrackerProgressDidFinish:self];
		}
	}

	[self.lock unlock];
}

- (void)progressStartedWithRequest:(NSURLRequest *)request
{
	[self.lock lock];

	[self.progressItems setObject:[[OTMWebViewProgressTrackerItem alloc]init] forKey:request];

	[self.lock unlock];
}

- (void)progressCompletedWithRequest:(NSURLRequest *)request
{
	[self.lock lock];

	[self.progressItems removeObjectForKey:request];

	[self.lock unlock];
}

- (void)incrementProgressForRequest:(NSURLRequest *)request withResponse:(NSURLResponse *)response
{
	[self.lock lock];

	long long estimatedLength = response.expectedContentLength;
	if (estimatedLength == NSURLResponseUnknownLength) {
		estimatedLength = kOTMWebViewProgressTrackerItemDefaultEstimatedLength;
	}
	self.totalBytesToLoad += estimatedLength;
	OTMWebViewProgressTrackerItem *item = [self.progressItems objectForKey:request];

	if ([response.MIMEType isEqualToString:@"text/html"]) {
		item.isHTML = YES;
	}

	item.estimatedLength = estimatedLength;

	[self.lock unlock];
}

- (void)incrementProgressForRequest:(NSURLRequest *)request withBytesReceived:(NSUInteger)bytesReceived
{
	[self.lock lock];

	OTMWebViewProgressTrackerItem *item = [self.progressItems objectForKey:request];
	self.totalBytesReceived += bytesReceived;
	if (item.bytesReceived > item.estimatedLength) {
		self.totalBytesToLoad += item.bytesReceived * 2 - item.estimatedLength;
		item.estimatedLength = item.bytesReceived * 2;
	}

	long long bytesLeft = self.totalBytesToLoad - self.totalBytesReceived;

	double ratioOfRemainingBytes = 1.0;
	if (bytesLeft > 0) {
		ratioOfRemainingBytes = (double)bytesReceived / (double)bytesLeft;
	}
	double maxProgress = item.isHTML ? 0.5 : kOTMWebViewProgressTrackerMaxProgressValue;
	double increment = (maxProgress - self.progress) * ratioOfRemainingBytes;

	self.progress = MIN(self.progress + increment,  maxProgress);

	self.totalBytesReceived += bytesReceived;

	[self.lock unlock];
}

@end
