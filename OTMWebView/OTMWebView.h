//
// OTMWebView.h
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
#import "OTMWebViewContextMenuItem.h"

extern NSString *const OTMWebViewElementTagNameKey;
extern NSString *const OTMWebViewElementHREFKey;
extern NSString *const OTMWebViewElementSRCKey;
extern NSString *const OTMWebViewElementTitleKey;
extern NSString *const OTMWebViewElementAltKey;
extern NSString *const OTMWebViewElementIDKey;
extern NSString *const OTMWebViewElementDocumentURL;

/**
 *  'OTMWebView' is a subclass of the 'UIWebView', adding several additions.
 */
@interface OTMWebView : UIWebView

/**
 *  The title of the web view's document.
 */
@property (readonly, copy, nonatomic) NSString *documentTitle;

///-----------------------------
/// @name Setting the user agent
///-----------------------------

/**
 *  Set the user agent for all requests that the web view makes, including all sub resources too.
 */
@property (copy, nonatomic) NSString *userAgent;

/**
 *  The current progress of the web view. Value from 0.0 to 1.0, it is estimated based off of the bytes expected to be loaded.
 */

///------------------------
/// @name Progress Tracking
///------------------------

@property (readonly, nonatomic) double progress;

///-------------------
/// @name Context Menu
///-------------------

@property (nonatomic) BOOL customContextMenuEnabled;

+(NSArray *)defaultContextMenuItemsForElement:(NSDictionary *)element;

+(OTMWebViewContextMenuItem *)openContextMenuItem;

+(OTMWebViewContextMenuItem *)saveImageContextMenuItem;

+(OTMWebViewContextMenuItem *)copyURLContextMenuItem;

+(OTMWebViewContextMenuItem *)copyImageContextMenuItem;

+(OTMWebViewContextMenuItem *)readingListContextMenuItem;

@end

/**
 *  The 'OTMWebView' delegate, extends the UIWebViewDelegate with new additions.
 */
@protocol OTMWebViewDelegate <UIWebViewDelegate>

@optional;

/**
 *  Sent when the main frame of the web view receives a response.
 *
 *  @param webView  The web view that received the response.
 *  @param response The response that the web view received.
 *  @param request  The request that was sent to receive the response.
 */
-(void)webView:(OTMWebView *)webView didReceiveResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request;

/**
 *  Sent when the document title of the web view has changed, including when a new document has been loaded.
 *
 *  @param webView The web view of the document with the title change.
 *  @param title   The new title of the web view.
 */
-(void)webView:(OTMWebView *)webView documentTitleDidChange:(NSString *)title;

///------------------------
/// @name Progress Tracking
///------------------------

/**
 *  Sent when the progress has started for the main frame of the web view.
 *
 *  @param webView The web view whose progress has started.
 */
-(void)webViewProgressDidStart:(OTMWebView *)webView;

/**
 *  Sent when the web view's document readyState is completed.
 *
 *  @param webView The web view whose progress is finished
 */
-(void)webViewProgressDidFinish:(OTMWebView *)webView;

/**
 *  Sent when the progress of the web view has changed.
 *
 *  @param webView  The web view whose progress has changed.
 *  @param progress The new progress of the web view.
 */
-(void)webView:(OTMWebView *)webView progressDidChange:(double)progress;

///-------------------
/// @name Context Menu
///-------------------

-(void)webView:(OTMWebView *)webView configureContextMenuActionSheet:(UIActionSheet *)actionSheet forElements:(NSArray *)elements;

-(NSArray *)webView:(OTMWebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems;

@end

