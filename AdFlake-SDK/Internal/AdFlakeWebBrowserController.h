/**
 * AdFlakeWebBrowserController.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeWebBrowserController.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdFlakeCustomAdView.h"

@class AdFlakeWebBrowserController;

@protocol AdFlakeWebBrowserControllerDelegate<NSObject>

- (void)webBrowserClosed:(AdFlakeWebBrowserController *)controller;

@end

/**
 * The AdFlakeWebBrowserController class provides an in-app
 * web browser that can be opened as a modal view.
 */
@interface AdFlakeWebBrowserController : UIViewController <UIWebViewDelegate> {
	id<AdFlakeWebBrowserControllerDelegate> delegate;
	UIViewController *viewControllerForPresenting;
	NSArray *loadingButtons;
	NSArray *loadedButtons;
	AFCustomAdWebViewAnimType transitionType;

	UIWebView *webView;
	UIToolbar *toolBar;
	UIBarButtonItem *navigateBackButton;
	UIBarButtonItem *navigateForwardButton;
	UIBarButtonItem *reloadButton;
	UIBarButtonItem *stopButton;
	UIBarButtonItem *linkOutButton;
	UIBarButtonItem *closeButton;
}

@property (nonatomic,assign) id<AdFlakeWebBrowserControllerDelegate> delegate;
@property (nonatomic,assign) UIViewController *viewControllerForPresenting;
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIToolbar *toolBar;
@property (nonatomic,retain) UIBarButtonItem *navigateBackButton;
@property (nonatomic,retain) UIBarButtonItem *navigateForwardButton;
@property (nonatomic,retain) UIBarButtonItem *reloadButton;
@property (nonatomic,retain) UIBarButtonItem *stopButton;
@property (nonatomic,retain) UIBarButtonItem *linkOutButton;
@property (nonatomic,retain) UIBarButtonItem *closeButton;

- (void)presentWithController:(UIViewController *)viewController transition:(AFCustomAdWebViewAnimType)animType;
- (void)loadURL:(NSURL *)url;
- (void)navigateBack:(id)sender;
- (void)navigateForward:(id)sender;
- (void)reload:(id)sender;
- (void)stop:(id)sender;
- (void)linkOut:(id)sender;
- (void)close:(id)sender;

@end

@interface AdFlakeBackButton : UIBarButtonItem
@end

