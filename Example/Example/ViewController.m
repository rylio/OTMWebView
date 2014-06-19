//
//  ViewController.m
//  Example
//
//  Created by Ryan on 5/25/14.
//  Copyright (c) 2014 Otium. All rights reserved.
//

#import "ViewController.h"
#import <OTMWebView/OTMWebView.h>

@interface ViewController ()<OTMWebViewDelegate>
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) OTMWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
-(void)barButtonItemAction:(UIBarButtonItem *)item;
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.webView = [[OTMWebView alloc]initWithFrame:CGRectZero];
	self.webView.translatesAutoresizingMaskIntoConstraints = NO;
	self.webView.delegate = self;
	[self.view addSubview:self.webView];
	
	self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectZero];
	self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.toolbar];
	
	[self.view addConstraints:@[
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.toolbar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]
								]];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
	
	
	
	self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
	
	UIBarButtonItem *progressItem = [[UIBarButtonItem alloc]initWithCustomView:self.progressView];
	
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];
	
	backItem.tag = 0;
	
	UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc]initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];
	forwardItem.tag = 1;
	
	self.toolbar.items = @[backItem, forwardItem, progressItem];
	
	
	
    // Do any additional setup after loading the view.
}

-(void)barButtonItemAction:(UIBarButtonItem *)item {
	
	if (item.tag == 0) {
		
		[self.webView goBack];
		
	}else if (item.tag == 1) {
		
		[self.webView goForward];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewProgressDidStart:(OTMWebView *)webView {
	
	self.progressView.progress = 0.0;
}


-(void)webView:(OTMWebView *)progressTracker progressDidChange:(double)progress {
	
	[self.progressView setProgress:progress animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
