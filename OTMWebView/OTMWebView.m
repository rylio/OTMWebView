//
// OTMWebView.m
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

#import <objc/runtime.h>
#import "OTMWebView.h"
#import "OTMWebViewURLProtocol.h"
#import "OTMWebViewProgressTracker.h"

NSString *const kOTMWebViewURLScheme = @"OTMWebView";

@interface OTMWebView ()<UIWebViewDelegate, OTMWebViewProgressTrackerDelegate>
+(NSString *)injectionScript;
@property (weak, nonatomic) id <UIWebViewDelegate> otm_delegate;
@property (strong, nonatomic) OTMWebViewProgressTracker *progressTracker;
@property (copy, nonatomic) NSString *documentTitle;
@end

@implementation OTMWebView

+(void)load {
	
	// swap the delegate property with our own private one,so we can internally set the delegate to ourselves,
	// and then forward the calls to the public delegate.
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		Method oldMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
		Method newMethod = class_getInstanceMethod([self class], @selector(setOtm_delegate:));
		
		method_exchangeImplementations(oldMethod, newMethod);
		
		oldMethod = class_getInstanceMethod([self class], @selector(delegate));
		newMethod = class_getInstanceMethod([self class], @selector(otm_delegate));
		
		method_exchangeImplementations(oldMethod, newMethod);
	});
	
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			[NSURLProtocol registerClass:[OTMWebViewURLProtocol class]];
		});
		self.otm_delegate = self;
		self.progressTracker = [[OTMWebViewProgressTracker alloc]init];
		self.progressTracker.delegate = self;
    }
    return self;
}

+(NSString *)injectionScript {
	
	static dispatch_once_t onceToken;
	static NSString *script;
	dispatch_once(&onceToken, ^{
		NSString *path = [[NSBundle mainBundle]pathForResource:@"OTMWebView" ofType:@"js"];
		NSError *error;
		script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
		if (error) {
			NSLog(@"unable to load injection script: %@",error.localizedDescription);
		}
	});
	
	return script;
}

-(void)setDocumentTitle:(NSString *)documentTitle {
	
	_documentTitle = documentTitle;
	
	if ([self.delegate respondsToSelector:@selector(webView:documentTitleDidChange:)]) {
		[(id<OTMWebViewDelegate>)self.delegate webView:self documentTitleDidChange:documentTitle];
	}
}

-(double)progress {
	
	return self.progressTracker.progress;
}

#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if ([request.URL.scheme compare:kOTMWebViewURLScheme options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		
		if ([request.URL.host isEqualToString:@"onReadyStateChange"]) {
			
			[self.progressTracker finishProgress];
			
		} else if ([request.URL.host isEqualToString:@"setDocumentTitle"]) {
			
			self.documentTitle = request.URL.path.lastPathComponent;
		}
		
		return NO;
	}
	
	NSAssert([request isKindOfClass:[NSMutableURLRequest class]], @"request is not mutable");
	
	NSMutableURLRequest *mutableRequest = (NSMutableURLRequest *)request;
	
	mutableRequest.URL = OTMWebViewURLByAddingWebViewIdentifier(mutableRequest.URL, (OTMWebView *)webView);
	mutableRequest.mainDocumentURL = OTMWebViewURLByAddingWebViewIdentifier(mutableRequest.mainDocumentURL, (OTMWebView *)webView);
	
	[OTMWebViewURLProtocol setProperty:self forKey:kOTMWebViewURLProtocolHandleRequestkey inRequest:mutableRequest];
	[OTMWebViewURLProtocol setProperty:self forKey:kOTMWebViewURLProtocolMainRequestKey inRequest:mutableRequest];
	
	BOOL shouldLoadRequest = YES;
	if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
		
		shouldLoadRequest = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
	}
	
	BOOL startProgress = YES;
	
	if (request.URL.fragment) {
		
		NSString *nonFragmentUrl1 = [request.URL.absoluteString substringToIndex:[request.URL.absoluteString rangeOfString:@"#"].location];
		
		NSRange range = [webView.request.URL.absoluteString rangeOfString:@"#"];
		
		NSString *nonFragmentUrl2 = range.location == NSNotFound ? webView.request.URL.absoluteString : [webView.request.URL.absoluteString substringToIndex:range.location];
		if ([nonFragmentUrl1 isEqualToString:nonFragmentUrl2]) {
			startProgress = NO;
		}
	}
	
	if (shouldLoadRequest && startProgress) {
				
		if ([mutableRequest.URL isEqual:mutableRequest.mainDocumentURL] || mutableRequest.mainDocumentURL == nil) {
			[self.progressTracker startProgress];
		}
	}
	return shouldLoadRequest;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
	
	if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
		
		[self.delegate webViewDidStartLoad:webView];
	}
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[webView stringByEvaluatingJavaScriptFromString:[[self class]injectionScript]];
	
	self.documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
	if ([readyState isEqualToString:@"complete"] || readyState == nil) {
		
		[self.progressTracker finishProgress];
	}
	if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
		
		[self.delegate webViewDidFinishLoad:webView];
	}
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	[self.progressTracker finishProgress];
	
	if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
		
		[self.delegate webView:webView didFailLoadWithError:error];
	}
}

#pragma mark = Progress Tracker Delegate

-(void)progressTrackerProgressDidStart:(OTMWebViewProgressTracker *)tracker {
	
	if ([self.delegate respondsToSelector:@selector(webViewProgressDidStart:)]) {
		[(id<OTMWebViewDelegate>)self.delegate webViewProgressDidStart:self];
	}
}

-(void)progressTrackerProgressDidFinish:(OTMWebViewProgressTracker *)tracker {
	
	if ([self.delegate respondsToSelector:@selector(webViewProgressDidFinish:)]) {
		[(id<OTMWebViewDelegate>)self.delegate webViewProgressDidFinish:self];
	}
}

-(void)progressTracker:(OTMWebViewProgressTracker *)progressTracker progressDidChange:(double)progress {
	
	if ([self.delegate respondsToSelector:@selector(webView:progressDidChange:)]) {
	
		[(id<OTMWebViewDelegate>)self.delegate webView:self progressDidChange:progress];
	}
}

@end
