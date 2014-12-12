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

#if defined(AdFlake_Enable_SDK_BeachfrontIO)

#import "AdFlakeAdapterAdBeachfrontVideo.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

@implementation AdFlakeAdapterAdBeachfrontVideo

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeBeachfrontIO;
}

+ (void)prepareForConfig:(AdFlakeAdNetworkConfig*)networkConfig
{
	AFLogDebug(@"%s:%@", __FUNCTION__, networkConfig);
}

- (void)getAd
{
	bool isTestMode = false;
	
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		isTestMode = true;
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beachFrontDidOpen) name:BFAdInterstitialOpenedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beachFrontDidStart) name:BFAdInterstitialStartedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beachFrontDidComplete) name:BFAdInterstitialCompletedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beachFrontDidClose) name:BFAdInterstitialClosedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beachFrontDidFail) name:BFAdInterstitialFailedNotification object:nil];
	
	// play video
	[BFIOSDK showInterstitialAdWithAppID:[self appID] adUnitID:[self zoneID]];
}

- (void)stopBeingDelegate
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Ad Request Lifecycle Notifications

- (void) beachFrontDidOpen
{
	AFLogDebug(@"%s:", __FUNCTION__);
	[self.adFlakeView adapterDidReceiveVideoAd:self];
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void) beachFrontDidStart
{
	AFLogDebug(@"%s:", __FUNCTION__);
}

- (void) beachFrontDidComplete
{
	AFLogDebug(@"%s:", __FUNCTION__);
	[self.adFlakeView adapterUserWatchedEntireVideoAdModal:self];
}

- (void) beachFrontDidClose
{
	AFLogDebug(@"%s:", __FUNCTION__);
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void) beachFrontDidFail
{
	AFLogDebug(@"%s:", __FUNCTION__);
	[self.adFlakeView adapter:self didFailVideoAd:[NSError errorWithDomain:@"BeachFront" code:404 userInfo:nil]];
}

#pragma mark parameter gathering methods

- (NSString *)appID
{
	if (([adFlakeDelegate respondsToSelector:@selector(adColonyVideoAppID)])) {
		return [adFlakeDelegate performSelector:@selector(adColonyVideoAppID)];
	}
	
	NSArray *keys = [networkConfig.pubId componentsSeparatedByString:@"|;|"];
	
	if (keys.count != 2)
		return @"";
	
	return [keys objectAtIndex:0];
}

- (NSString *)zoneID
{
	if (([adFlakeDelegate respondsToSelector:@selector(adColonyVideoZoneID)])) {
		return [adFlakeDelegate performSelector:@selector(adColonyVideoZoneID)];
	}
	
	NSArray *keys = [networkConfig.pubId componentsSeparatedByString:@"|;|"];
	
	if (keys.count != 2)
		return @"";
	
	return [keys objectAtIndex:1];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end

#endif
