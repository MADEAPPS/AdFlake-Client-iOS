/**
 * AdFlakeWebBrowserController.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeWebBrowserController.m
 * @copyright 2013 MADE GmbH. All rights reserved.
 * @section License
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AdFlakeWebBrowserController.h"
#import "AdFlakeCommon.h"

#define kAWWebViewAnimDuration 1.0

@interface AdFlakeWebBrowserController ()
@property (nonatomic,retain) NSArray *loadingButtons;
@property (nonatomic,retain) NSArray *loadedButtons;
@end


// NOTE: we're disabling deprecated warning since we're also using the newer API
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation AdFlakeWebBrowserController

@synthesize delegate;
@synthesize viewControllerForPresenting;
@synthesize loadingButtons;
@synthesize loadedButtons;

@synthesize webView;
@synthesize toolBar;
@synthesize navigateBackButton;
@synthesize navigateForwardButton;
@synthesize reloadButton;
@synthesize stopButton;
@synthesize linkOutButton;
@synthesize closeButton;


- (id)init
{
	if ((self = [super init]))
	{

	}

	return self;
}

- (void) loadView
{
	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 436.0)] autorelease];
	self.webView.autoresizesSubviews = YES;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.backgroundColor = [UIColor whiteColor];
	self.webView.hidden = NO;
	self.webView.multipleTouchEnabled = YES;
	self.webView.opaque = YES;
	self.webView.scalesPageToFit = YES;
	self.webView.tag = 2000;
	self.webView.delegate = self;
	self.webView.userInteractionEnabled = YES;

	self.toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 436.0, 320.0, 44.0)] autorelease];
	self.toolBar.autoresizesSubviews = YES;
	self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	self.toolBar.barStyle = UIBarStyleDefault;
	self.toolBar.hidden = NO;
	self.toolBar.multipleTouchEnabled = NO;
	self.toolBar.opaque = NO;
	self.toolBar.tag = 1000;
	self.toolBar.userInteractionEnabled = YES;

	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)] autorelease];
	self.view.alpha = 1.000;
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor colorWithWhite:0.000 alpha:1.000];
	self.view.clearsContextBeforeDrawing = YES;
	self.view.clipsToBounds = NO;
	self.view.contentMode = UIViewContentModeScaleToFill;
	self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	self.view.hidden = NO;
	self.view.multipleTouchEnabled = NO;
	self.view.opaque = YES;
	self.view.tag = 0;
	self.view.userInteractionEnabled = YES;

	[self.view addSubview:self.webView];
	[self.view addSubview:self.toolBar];


	self.navigateBackButton = [[[AdFlakeBackButton alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(navigateBack:)] autorelease];
	self.navigateBackButton.enabled = YES;
	self.navigateBackButton.tag = 1001;

	self.navigateForwardButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(navigateForward:)] autorelease];
	self.navigateForwardButton.enabled = NO;
	self.navigateForwardButton.tag = 1002;

	self.reloadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] autorelease];
	self.reloadButton.enabled = NO;
	self.reloadButton.tag = 1003;

	self.stopButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)] autorelease];
	self.stopButton.enabled = NO;
	self.stopButton.tag = 1004;

	self.linkOutButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(linkOut:)] autorelease];
	self.linkOutButton.enabled = NO;
	self.linkOutButton.tag = 1005;

	self.closeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)] autorelease];
	self.closeButton.enabled = YES;
	self.closeButton.tag = 1006;


	NSMutableArray *barItems = [NSMutableArray arrayWithCapacity:10];
	[barItems addObject:self.navigateBackButton];
	[barItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[barItems addObject:self.navigateForwardButton];
	[barItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[barItems addObject:self.reloadButton];
	[barItems addObject:self.stopButton];
	[barItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[barItems addObject:self.linkOutButton];
	[barItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[barItems addObject:self.closeButton];

	[self.toolBar setItems:barItems animated:false];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.webView.request) {
		// has content from before, clear by creating another UIWebView
		CGRect frame = self.webView.frame;
		NSInteger tag = self.webView.tag;
		UIWebView *newView = [[UIWebView alloc] initWithFrame:frame];
		newView.tag = tag;
		UIWebView *oldView = self.webView;
		[oldView removeFromSuperview];
		[self.view addSubview:newView];
		newView.delegate = self;
		newView.scalesPageToFit = YES;
		[newView release];
	}
	self.toolBar.items = self.loadedButtons;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSArray *items = self.toolBar.items;

	NSMutableArray *loadingItems = [[NSMutableArray alloc] init];
	[loadingItems addObjectsFromArray:items];
	[loadingItems removeObjectAtIndex:4];
	self.loadingButtons = loadingItems;
	[loadingItems release], loadingItems = nil;

	NSMutableArray *loadedItems = [[NSMutableArray alloc] init];
	[loadedItems addObjectsFromArray:items];
	[loadedItems removeObjectAtIndex:5];
	self.loadedButtons = loadedItems;
	[loadedItems release], loadedItems = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.delegate) {
		[delegate webBrowserClosed:self];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [viewControllerForPresenting shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)presentWithController:(UIViewController *)viewController transition:(AFCustomAdWebViewAnimType)animType
{
	self.viewControllerForPresenting = viewController;

	if ([self respondsToSelector:@selector(setModalTransitionStyle:)]) {
		switch (animType) {
			case AFCustomAdWebViewAnimTypeFlipFromLeft:
			case AFCustomAdWebViewAnimTypeFlipFromRight:
				self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				break;
			case AFCustomAdWebViewAnimTypeFadeIn:
				self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			case AFCustomAdWebViewAnimTypeModal:
			default:
				self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				break;
		}
	}

	if ([viewController respondsToSelector:@selector(presentViewController:animated:completion:)])
	{
		[viewController presentViewController:self animated:YES completion:^{

		}];
	}
	else
	{
		[viewController presentModalViewController:self animated:YES];
	}
}

- (void)loadURL:(NSURL *)url {
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:urlRequest];
}

- (void)dealloc
{
	self.loadingButtons = nil;
	self.loadedButtons = nil;

	self.webView.delegate = nil;
	self.webView = nil;
	self.toolBar = nil;

	self.navigateBackButton = nil;
	self.navigateForwardButton = nil;
	self.reloadButton = nil;
	self.closeButton = nil;
	self.linkOutButton = nil;
	self.stopButton = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	if ([request URL] != nil && [[request URL] scheme] != nil) {
		if ([[[request URL] scheme] isEqualToString:@"mailto"]) {
			// need to explicitly call out to the Mail app
			[[UIApplication sharedApplication] openURL:[request URL]];
		}
	}
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.toolBar.items = self.loadedButtons;
	if (self.webView.canGoForward) {
		self.navigateForwardButton.enabled = YES;
	}
	if (self.webView.canGoBack) {
		self.navigateBackButton.enabled = YES;
	}
	self.reloadButton.enabled = YES;
	self.stopButton.enabled = NO;
	if (self.webView.request) {
		self.linkOutButton.enabled = YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.toolBar.items = self.loadedButtons;
	if (self.webView.canGoForward) {
		self.navigateForwardButton.enabled = YES;
	}
	if (self.webView.canGoBack) {
		self.navigateBackButton.enabled = YES;
	}
	self.reloadButton.enabled = YES;
	self.stopButton.enabled = NO;
	if (self.webView.request) {
		self.linkOutButton.enabled = YES;
	}

	//  // extract title of page
	//  NSString* title = [self.webView stringByEvaluatingJavaScriptFromString: @"document.title"];
	//  self.navigationItem.title = title;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.toolBar.items = self.loadingButtons;
	self.navigateForwardButton.enabled = NO;
	self.navigateBackButton.enabled = NO;
	self.reloadButton.enabled = NO;
	self.stopButton.enabled = YES;
}

#pragma mark -
#pragma mark button targets

- (void)navigateForward:(id)sender
{
	NSLog(@"%s", __FUNCTION__);

	[self.webView goForward];
}

- (void)navigateBack:(id)sender
{
	NSLog(@"%s", __FUNCTION__);

	[self.webView goBack];
}

- (void)stop:(id)sender
{
	NSLog(@"%s", __FUNCTION__);

	[self.webView stopLoading];
}

- (void)reload:(id)sender
{
	NSLog(@"%s", __FUNCTION__);

	[self.webView reload];
}

- (void)linkOut:(id)sender
{
	NSLog(@"%s", __FUNCTION__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)close:(id)sender
{
	NSLog(@"%s", __FUNCTION__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if ([viewControllerForPresenting respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
	{
		[viewControllerForPresenting dismissViewControllerAnimated:YES completion:^{

		}];
	}
	else
	{
		[viewControllerForPresenting dismissModalViewControllerAnimated:YES];
	}
}

@end


@implementation AdFlakeBackButton

- (id) initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	const float scale = [UIScreen mainScreen].scale;

	// draw the back image
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(nil, 25*scale, 25*scale, 8, 0, colorspace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorspace);
	CGPoint bot = CGPointMake(19*scale, 4*scale);
	CGPoint top = CGPointMake(19*scale, 22*scale);
	CGPoint tip = CGPointMake(4*scale, 13*scale);
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextMoveToPoint(ctx, bot.x, bot.y);
	CGContextAddLineToPoint(ctx, tip.x, tip.y);
	CGContextAddLineToPoint(ctx, top.x, top.y);
	CGContextFillPath(ctx);

	// set the image
	CGImageRef backImgRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	UIImage* backImage = [[UIImage alloc] initWithCGImage:backImgRef scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(backImgRef);

	if ((self = [super initWithImage:backImage style:style target:target action:action]))
	{
	}
	[backImage release];

	return self;
}


@end
