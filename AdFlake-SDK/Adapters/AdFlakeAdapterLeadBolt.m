/**
 * AdFlakeAdapterLeadBolt.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterLeadBolt.m
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

#if defined(AdFlake_Enable_SDK_LeadBolt)

#import "AdFlakeAdapterLeadBolt.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "LeadBoltOverlay.h"


@implementation AdFlakeAdapterLeadBolt

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType
{
	return AdFlakeAdNetworkTypeLeadBolt;
}

- (void)getAd
{
	_container = [[UIView alloc] initWithFrame:kAdFlakeViewDefaultFrame];
	[_container setBackgroundColor:[self helperBackgroundColorToUse]];


	LeadboltOverlay *adView = [LeadboltOverlay createAdWithSectionid:self.networkConfig.pubId view:_container];

	[adView setLocationControl:@"0"];

	if (adFlakeConfig.locationOn) {
		[adView setLocationControl:@"1"];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdLoaded:) name:@"onAdLoaded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdFailed) name:@"onAdFailed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdClicked) name:@"onAdClicked" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdClosed) name:@"onAdClosed" object:nil];

	[adView loadAd];
}

- (void)stopBeingDelegate
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc
{
	[_container release];
	[super dealloc];
}

#pragma mark - LeadBolt delegate

- (void)onAdClosed
{
	[[adFlakeDelegate viewControllerForPresentingModalView] dismissViewControllerAnimated:NO completion:^{

		[_container setFrame:kAdFlakeViewDefaultFrame];
		[_container removeFromSuperview];
		[self.adFlakeView addSubview:_container];
	}];
}

- (void)onAdClicked
{
	[_container removeFromSuperview];

	UIViewController *controller = [[[UIViewController alloc] init] autorelease];
	controller.view = _container;

	[[adFlakeDelegate viewControllerForPresentingModalView] presentModalViewController:controller animated:YES];
}

- (void)onAdLoaded:(id)sender
{
	if (_container.subviews.count == 0)
	{
		[self onAdFailed];
		return;
	}

	UIView *adView = [_container.subviews objectAtIndex:0];
	adView.frame = kAdFlakeViewDefaultFrame;

	[self.adFlakeView adapter:self didReceiveAdView:_container];
}


- (void)onAdFailed
{
	[self.adFlakeView adapter:self didFailAd:[NSError errorWithDomain:@"Unknown LeadBolt error" code:0 userInfo:nil]];
}


@end

#endif