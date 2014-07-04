//
//  OTMWebViewContextMenuItem.h
//  
//
//  Created by Ryan on 6/29/14.
//
//

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
-(instancetype)initWithTitle:(NSString *)title actionHandler:(void (^)(OTMWebView *webView, NSDictionary *element))actionHandler;

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
