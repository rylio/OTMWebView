//
// OTMWebViewContextMenuItem.h
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

#import <Foundation/Foundation.h>

@class OTMWebView;

@interface OTMWebViewContextMenuItem : NSObject

/**
 *  Initializes and return new context menu item with title and action handler set.
 *
 *  @param title         Sets the context menu item's title.
 *  @param actionHandler Sets the context menu item's action handler.
 *
 *  @return Returns the initialized context menu item.
 */
- (instancetype)initWithTitle:(NSString *)title actionHandler:(void (^)(OTMWebView *webView, NSDictionary *element))actionHandler;

/**
 *  Set to return the title for the item, use instead of title property for element-specific title.
 */
@property (copy, nonatomic) NSString * (^titleForElement)(OTMWebView *webView, NSDictionary *element);

/**
 *  Title of item, set titleForElement block for more element-specific title.
 */
@property (copy, nonatomic) NSString *title;

/**
 *  The action the context menu item is to perform.
 */
@property (copy, nonatomic) void (^actionHandler)(OTMWebView *webView, NSDictionary *element);

@end
