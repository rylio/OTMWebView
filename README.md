# OTMWebView

`OTMWebView` is a `UIWebView` subclass that attempts to bring some of missing features of the `UIWebView` to iOS.

## Features
- Progress tracking
- Setting user agent for all requests from the web view
- Response handling
- Document title change detection

## Usage
Set up `OTMWebView` instance

```objective-c
#import <OTMWebView/OTMWebView.h>

OTMWebView *webView = [[OTMWebView alloc]initWithFrame:CGRectZero];
webView.delegate = ....;
webView.userAgent = @"My User Agent String";

```
`OTMWebViewDelegate`
```objective-c
#import <OTMWebView/OTMWebView.h>

-(void)webView:(OTMWebView *)webView didReceiveResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request {

	if ([response.MIMEType isEqualToString:@"video/mp4"]) {

		[webView stopLoading];
		// Do something else...
	}
}

-(void)webView:(OTMWebView *)webView documentTitleDidChange:(NSString *)title {

	//Do something with new title...
}

-(void)webViewProgressDidStart:(OTMWebView *)webView {

	// web view's main frame started loading a document
}

-(void)webViewProgressDidFinish:(OTMWebView *)webView {

	// web view's document finished loading, as did all of its subresources
}

-(void)webView:(OTMWebView *)webView progressDidChange:(double)progress {

	// Update some sort of progress indicator
}
```
## Installation
[Cocoapods](http://cocoapods.org) is the recommended way to install `OTMWebView`. Just add `pod 'OTMWebView'` to your `Podfile`.

## Intercepting the URL requests of an `OTMWebView` with `NSURLProtocol`

Steps

1. In `OTMWebView's` delegate method: `- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType`
	- Set a property in the request with `NSURLProtocol's` `+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request` to tell our `NSURLProtocol` subclass to handle the request.
	- Attach identifier string to the request's url fragment component so we identify the `OTMWebView` instance
2. In the `NSURLProtocol` subclass's class method `+ (BOOL)canInitWithRequest:(NSURLRequest *)request` method
	- Check if ignore property is set with `NSURLProtocol's` `+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request`, if it is `return NO`
	- Check if the handle request property is set with `NSURLProtocol's` `+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request`, if it is `return YES`
	- Check the `mainDocumentURL` property of the request to see if it contains the identifier of a `OTMWebView` instance. If it is `return YES`
		- The `mainDocumentURL` property of requests for subresources is set the to web view's main request url. This allows us to identify the `OTMWebView` instance.

## Progress Tracking

Since `OTMWebView` is able to intercept the web view's main requests and the the requests for its subresources, it can track the download progress for all those resources, enabling it to be able to use a similar algorithm to Webkit's to estimate the loading progress of an entire document.

## License

OTMWebView is available under the MIT license. See the LICENSE file for more info.
