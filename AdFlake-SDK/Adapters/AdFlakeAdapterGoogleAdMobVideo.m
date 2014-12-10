/**
 * AdFlakeAdapterGoogleAdMob.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterGoogleAdMob.m
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

#if defined(AdFlake_Enable_SDK_GoogleAdMob)

#import "AdFlakeAdapterGoogleAdMobVideo.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "GADInterstitial.h"

@implementation AdFlakeAdapterGoogleAdMobVideo

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeAdMobVideo;
}

- (void)getAd
{
	GADRequest *request = [GADRequest request];
	
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		request.testing = YES;
		request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
	}
	
	_interstitial = [[GADInterstitial alloc] init];
	_interstitial.adUnitID = [self adUnitID];
	_interstitial.delegate = self;
	[_interstitial loadRequest:request];
	
}

- (void)stopBeingDelegate
{
	if (_interstitial != nil) {
		_interstitial.delegate = nil;
	}
}

#pragma mark Ad Request Lifecycle Notifications

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
	[self.adFlakeView adapterDidReceiveVideoAd:self];
	
	[_interstitial presentFromRootViewController:[self.adFlakeDelegate viewControllerForPresentingModalView]];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
	[self.adFlakeView adapter:self didFailVideoAd:error];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
	[self.adFlakeView adapterUserWatchedEntireVideoAdModal:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial
{
}

#pragma mark parameter gathering methods

- (NSString *)adUnitID
{
	if (([adFlakeDelegate respondsToSelector:@selector(admobVideoAdUnitID)])) {
		return [adFlakeDelegate performSelector:@selector(admobVideoAdUnitID)];
	}

	return networkConfig.pubId;
}

- (void) dealloc
{
	[_interstitial release];
	_interstitial = nil;
	
	[super dealloc];
}

@end

#endif
