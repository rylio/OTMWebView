//
//  OTMWebViewContextMenuItem.m
//  
//
//  Created by Ryan on 6/29/14.
//
//

#import "OTMWebViewContextMenuItem.h"

@interface OTMWebViewContextMenuItem ()

@end

@implementation OTMWebViewContextMenuItem

-(instancetype)initWithTitle:(NSString *)title actionHandler:(void (^)(OTMWebView *, NSDictionary *))actionHandler {
	
	self = [super init];
	
	if (self) {
		
		self.title = title;
		self.actionHandler = actionHandler;
	}
	
	return self;
}

@end
