//
//  ViewController.m
//  Example
//
//  Created by Ryan on 5/25/14.
//  Copyright (c) 2014 Otium. All rights reserved.
//

#import "ViewController.h"
#import <OTMWebView/OTMWebView.h>
#import <OTMWebView/OTMWebViewProgressBar.h>

@interface ViewController ()<OTMWebViewDelegate>
@property (strong, nonatomic) OTMWebView *webView;
@property (strong, nonatomic) OTMWebViewProgressBar *progressBar;
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
	self.webView.scalesPageToFit = YES;
	[self.view addSubview:self.webView];
	
	[self.view addConstraints:@[
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
								[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],

								]];
	

	
	UINavigationBar *navBar = self.navigationController.navigationBar;
	self.progressBar = [[OTMWebViewProgressBar alloc]init];
	CGFloat progressBarHeight = 3.0;
	self.progressBar.frame = CGRectMake(0.0, CGRectGetMaxY(navBar.bounds) - progressBarHeight , CGRectGetWidth(navBar.bounds), progressBarHeight);
	self.progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[navBar addSubview:self.progressBar];

	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
	
		
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];
	
	backItem.tag = 0;
	
	UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc]initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];
	forwardItem.tag = 1;
	
	self.toolbarItems = @[backItem, forwardItem];
	self.navigationController.toolbarHidden = NO;
}

-(void)barButtonItemAction:(UIBarButtonItem *)item {
	
	if (item.tag == 0) {
		
		[self.webView goBack];
		
	} else if (item.tag == 1) {
		
		[self.webView goForward];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewProgressDidStart:(OTMWebView *)webView {

}

-(void)webView:(OTMWebView *)progressTracker progressDidChange:(double)progress {
	
	[self.progressBar setProgress:progress animated:YES];
}

-(void)webViewProgressDidFinish:(OTMWebView *)webView {
	
	/*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.progressView setProgress:0.0];

	});
	*/
}

-(void)webView:(OTMWebView *)webView documentTitleDidChange:(NSString *)title {
	
	self.navigationItem.title = title;
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
