//
// OTMWebViewURLProtocol.m
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

#include <pthread.h>
#import "OTMWebViewURLProtocol.h"
#import "OTMWebViewProgressTracker.h"

NSString *const kOTMWebViewURLProtocolIgnoreRequestKey = @"otm_webview_ignore_request";
NSString *const kOTMWebViewURLProtocolHandleRequestkey = @"otm_webview_handle_request";
NSString *const kOTMWebViewURLProtocolMainRequestKey = @"otm_webview_main_request";
NSString *const kOTMWebViewURLProtocolRedirectRequestKey = @"otm_webview_redirect_request";

@interface OTMWebViewURLProtocol () <NSURLConnectionDataDelegate>
@property (weak, nonatomic) OTMWebView *webView;
@property (strong, nonatomic) NSURLConnection *connection;
+ (void)trackWebView:(OTMWebView *)webView;
+ (void)untrackWebView:(OTMWebView *)webView;
+ (BOOL)isTrackingWebView:(OTMWebView *)webView;
+ (OTMWebView *)trackedWebViewForKey:(NSString *)key;
@end

@interface OTMWebView ()
@property (readonly, strong, nonatomic) OTMWebViewProgressTracker *progressTracker;
@end

@implementation OTMWebViewURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	if ([[self class]propertyForKey:kOTMWebViewURLProtocolIgnoreRequestKey inRequest:request]) {
		return NO;
	}
	else if ([[self class]propertyForKey:kOTMWebViewURLProtocolHandleRequestkey inRequest:request]) {
		return YES;
	}
	else if ([[self class]trackedWebViewForKey:OTMWebViewExtractWebViewIdentifierFromURL(request.mainDocumentURL)]) {
		return YES;
	}

	return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient> )client
{
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	self = [super initWithRequest:mutableRequest cachedResponse:cachedResponse client:client];

	if (self) {
		mutableRequest.URL = OTMWebViewURLByRemovingWebViewIdentifier(mutableRequest.URL);

		[[self class]setProperty:@"" forKey:kOTMWebViewURLProtocolIgnoreRequestKey inRequest:mutableRequest];

		self.webView = [[self class]propertyForKey:kOTMWebViewURLProtocolHandleRequestkey inRequest:mutableRequest];

		if (!self.webView) {
			self.webView = [[self class]trackedWebViewForKey:OTMWebViewExtractWebViewIdentifierFromURL(request.mainDocumentURL)];
		}

		NSAssert(self.webView != nil, @"WebView should not be nil");

		if (self.webView.userAgent) {
			[mutableRequest setValue:self.webView.userAgent forHTTPHeaderField:@"User-Agent"];
		}

		self.connection = [[NSURLConnection alloc]initWithRequest:mutableRequest delegate:self startImmediately:NO];
		[[self class]trackWebView:self.webView];
	}

	return self;
}

- (void)startLoading
{
	[self.connection start];
	[self.webView.progressTracker progressStartedWithRequest:self.request];
}

- (void)stopLoading
{
	[self.webView.progressTracker progressCompletedWithRequest:self.request];
	[self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
	if (response) {
		NSMutableURLRequest *mutableRequest = [request mutableCopy];

		mutableRequest.URL = OTMWebViewURLByAddingWebViewIdentifier(mutableRequest.URL, self.webView);

		[[self class]removePropertyForKey:kOTMWebViewURLProtocolIgnoreRequestKey inRequest:mutableRequest];

		[[self class]setProperty:self.webView forKey:kOTMWebViewURLProtocolHandleRequestkey inRequest:mutableRequest];
		[[self class]setProperty:@"" forKey:kOTMWebViewURLProtocolRedirectRequestKey inRequest:mutableRequest];

		[self.client URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:response];

		[self.connection cancel];

		[self connection:self.connection didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];

		return mutableRequest;
	}

	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([[self class]propertyForKey:kOTMWebViewURLProtocolMainRequestKey inRequest:self.request]) {
		if ([self.webView.delegate respondsToSelector:@selector(webView:didReceiveResponse:forRequest:)]) {
			[(id < OTMWebViewDelegate >)self.webView.delegate webView : self.webView didReceiveResponse : response forRequest : self.request];
		}
	}

	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

	[self.webView.progressTracker incrementProgressForRequest:self.request withResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.client URLProtocol:self didLoadData:data];
	[self.webView.progressTracker incrementProgressForRequest:self.request withBytesReceived:data.length];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.client URLProtocol:self didFailWithError:error];
	[self.webView.progressTracker progressCompletedWithRequest:self.request];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.client URLProtocolDidFinishLoading:self];
	[self.webView.progressTracker progressCompletedWithRequest:self.request];
}

#pragma mark - WebView Resource Tracking

static NSMapTable *trackedWebViews;

static pthread_rwlock_t trackedWebViewsLock = PTHREAD_RWLOCK_INITIALIZER;

+ (void)trackWebView:(OTMWebView *)webView
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    trackedWebViews = [NSMapTable strongToWeakObjectsMapTable];
	});

	pthread_rwlock_wrlock(&trackedWebViewsLock);

	[trackedWebViews setObject:webView forKey:@(webView.hash).stringValue];

	pthread_rwlock_unlock(&trackedWebViewsLock);
}

+ (void)untrackWebView:(OTMWebView *)webView
{
	pthread_rwlock_wrlock(&trackedWebViewsLock);

	[trackedWebViews removeObjectForKey:@(webView.hash).stringValue];

	pthread_rwlock_unlock(&trackedWebViewsLock);
}

+ (BOOL)isTrackingWebView:(OTMWebView *)webView
{
	pthread_rwlock_rdlock(&trackedWebViewsLock);

	BOOL isTracking = [trackedWebViews objectForKey:@(webView.hash).stringValue] != nil;

	pthread_rwlock_unlock(&trackedWebViewsLock);

	return isTracking;
}

+ (OTMWebView *)trackedWebViewForKey:(NSString *)key
{
	pthread_rwlock_rdlock(&trackedWebViewsLock);

	OTMWebView *webView = [trackedWebViews objectForKey:key];

	pthread_rwlock_unlock(&trackedWebViewsLock);

	return webView;
}

@end

NSString *const kOTMWebViewURLIdentifierString = @"__OTMWebView__";

NSURL *OTMWebViewURLByAddingWebViewIdentifier(NSURL *url, OTMWebView *webView) {
	NSString *identifierString = [NSString stringWithFormat:@"%@%@", kOTMWebViewURLIdentifierString, @(webView.hash).stringValue];
	if ([url.absoluteString rangeOfString:identifierString].location != NSNotFound) {
		return url;
	}

	NSString *urlString = [url.absoluteString stringByAppendingString:[NSString stringWithFormat:@"%@%@", url.fragment ? @"":@"#", identifierString]];

	return [NSURL URLWithString:urlString];
}

NSURL *OTMWebViewURLByRemovingWebViewIdentifier(NSURL *url) {
	NSMutableString *urlString = [url.absoluteString mutableCopy];

	NSRange range = [urlString rangeOfString:kOTMWebViewURLIdentifierString];

	if (range.location == NSNotFound) {
		return url;
	}

	NSUInteger location = [urlString characterAtIndex:range.location - 1] == '#' ? range.location - 1 : range.location;
	[urlString deleteCharactersInRange:NSMakeRange(location, urlString.length - location)];

	return [NSURL URLWithString:urlString];
}

NSString *OTMWebViewExtractWebViewIdentifierFromURL(NSURL *url) {
	NSString *urlString = url.absoluteString;

	NSRange range = [urlString rangeOfString:kOTMWebViewURLIdentifierString];

	if (range.location == NSNotFound) {
		return nil;
	}

	return [urlString substringFromIndex:range.location + range.length];
}
