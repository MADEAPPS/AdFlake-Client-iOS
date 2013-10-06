/**
 * AdFlakeAdapterMobClix.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterMobClix.m
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

#if defined(AdFlake_Enable_SDK_MobClix)

#include "AdFlakeAdapterMobClix.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "Mobclix.h"
#import "MobclixAds.h"

@implementation AdFlakeAdapterMobClix

+ (AdFlakeAdNetworkType)networkType
{
	return AdFlakeAdNetworkTypeMobClix;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (BOOL)useTestAd {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
	{
		return [adFlakeDelegate adFlakeTestMode];
	}
	return NO;
}


- (void)getAd
{
	static bool isSdkInitialized = false;

	if (isSdkInitialized == false)
	{
		[Mobclix startWithApplicationId:[self mobClixAppID]];
		isSdkInitialized = true;
	}

	MobclixAdViewiPhone_320x50 *adView = [[[MobclixAdViewiPhone_320x50 alloc] initWithFrame:kAdFlakeViewDefaultFrame] autorelease];
	adView.delegate = self;

	[adView getAd];

	self.adNetworkView = adView;
}

- (void)stopBeingDelegate
{
	MobclixAdViewiPhone_320x50 *adView = (MobclixAdViewiPhone_320x50*)self.adNetworkView;
	if (adView != nil)
	{
		[adView cancelAd];
		adView.delegate = nil;
	}
}

- (NSString*) mobClixAppID
{
	if([self useTestAd])
	{
		return @"insert-your-application-key";
	}
	if ([adFlakeDelegate respondsToSelector:@selector(mobClixAppIDString)]) {
		return [adFlakeDelegate mobClixAppIDString];
	}

	return [networkConfig.credentials valueForKey:@"appID"];
}

#pragma mark - MobclixAdViewDelegate implemenations

- (void)adViewDidFinishLoad:(MobclixAdView*)adView
{
	[self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)adView:(MobclixAdView*)adView didFailLoadWithError:(NSError*)error
{
	[self.adFlakeView adapter:self didFailAd:error];
}

@end

#endif