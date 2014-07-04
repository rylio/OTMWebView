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

-(instancetype)initWithTitle:(NSString *)title actionHandler:(void (^)(OTMWebView *webView, NSDictionary *element))actionHandler;

@property (copy, nonatomic) NSString * (^titleForElement)(OTMWebView *webView, NSDictionary *element);
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) void (^actionHandler)(OTMWebView *webView, NSDictionary *element);

@end
