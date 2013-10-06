/**
 * AdFlakeAdapterIAd.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterIAd.m
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

#import "AdFlakeConfiguration.h"

#if defined(AdFlake_Enable_SDK_AppleIAD)

// NOTE: we're disabling deprecated warning since we're also using the newer API
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "AdFlakeAdapterIAd.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

@implementation AdFlakeAdapterIAd

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeIAd;
}

+ (void)load {
	if(NSClassFromString(@"ADBannerView") != nil) {
		[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
	}
}

- (void)getAd {
	kADBannerContentSizeIdentifierPortrait = &ADBannerContentSizeIdentifierPortrait != nil ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
	kADBannerContentSizeIdentifierLandscape = &ADBannerContentSizeIdentifierLandscape != nil ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;

	ADBannerView *iAdView;
	if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
		iAdView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
		iAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	} else {
		iAdView = [[ADBannerView alloc] initWithFrame:CGRectZero];
		iAdView.requiredContentSizeIdentifiers =
        [NSSet setWithObjects:
		 kADBannerContentSizeIdentifierPortrait,
		 kADBannerContentSizeIdentifierLandscape,
		 nil];
	}

	[iAdView setDelegate:self];

	self.adNetworkView = iAdView;
	[iAdView release];
}

- (void)stopBeingDelegate {
	ADBannerView *iAdView = (ADBannerView *)self.adNetworkView;
	if (iAdView != nil) {
		iAdView.delegate = nil;
	}
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
	ADBannerView *iAdView = (ADBannerView *)self.adNetworkView;
	if (iAdView == nil) return;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierLandscape;
	}
	else {
		iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierPortrait;
	}

	// ADBanner positions itself in the center of the super view, which we do not
	// want, since we rely on publishers to resize the container view.
	// position back to 0,0
	CGRect newFrame = iAdView.frame;
	newFrame.origin.x = newFrame.origin.y = 0;
	iAdView.frame = newFrame;
}

- (BOOL)isBannerAnimationOK:(AFBannerAnimationType)animType {
	if (animType == AFBannerAnimationTypeFadeIn) {
		return NO;
	}
	return YES;
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark IAdDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	// ADBanner positions itself in the center of the super view, which we do not
	// want, since we rely on publishers to resize the container view.
	// position back to 0,0
	CGRect newFrame = banner.frame;
	newFrame.origin.x = newFrame.origin.y = 0;
	banner.frame = newFrame;

	[adFlakeView adapter:self didReceiveAdView:banner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[adFlakeView adapter:self didFailAd:error];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	[self helperNotifyDelegateOfFullScreenModal];
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end

#endif