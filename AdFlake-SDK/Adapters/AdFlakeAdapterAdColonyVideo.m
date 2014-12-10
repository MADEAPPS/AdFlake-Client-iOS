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

#if defined(AdFlake_Enable_SDK_AdColony)

#import "AdFlakeAdapterAdColonyVideo.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "GADInterstitial.h"

@implementation AdFlakeAdapterAdColonyVideo

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeAdColony;
}

+ (void)prepareForConfig:(AdFlakeAdNetworkConfig*)networkConfig
{
	AFLogDebug(@"%s:%@", __FUNCTION__, networkConfig);
	
	// NOTE: we preload our configuration
	AdFlakeAdapterAdColonyVideo *tempAdapter = [[AdFlakeAdapterAdColonyVideo alloc] initWithAdFlakeDelegate:nil
																									   view:nil
																									 config:nil
																							  networkConfig:networkConfig];
	
	
	[AdColony configureWithAppID:[tempAdapter appID]
						 zoneIDs:@[[tempAdapter zoneID]]
						delegate:nil
						 logging:YES];
	
	[tempAdapter release];
}

- (void)getAd
{
	bool isTestMode = false;
	
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		isTestMode = true;
	}
	
	[AdColony configureWithAppID:[self appID]
						 zoneIDs:@[[self zoneID]]
						delegate:self
						 logging:isTestMode];

	// give this a few seconds
	[self performSelector:@selector(tryPlayVideo) withObject:[self zoneID] afterDelay:0.0f];
}

- (void)tryPlayVideo
{
	[AdColony playVideoAdForZone:[self zoneID] withDelegate:self];
}

- (void)stopBeingDelegate
{ 
}

#pragma mark Ad Request Lifecycle Notifications

- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID;
{
	AFLogDebug(@"%s:%i zone:%@", __FUNCTION__, available, zoneID);
}

- (void) onAdColonyAdStartedInZone:(NSString *)zoneID
{
	AFLogDebug(@"%s", __FUNCTION__);
	
	[self.adFlakeView adapterDidReceiveVideoAd:self];
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
	AFLogDebug(@"%s", __FUNCTION__);
	
	if (!shown)
	{
		[self.adFlakeView adapter:self didFailVideoAd:[NSError errorWithDomain:@"AdColony" code:404 userInfo:nil]];
		return;
	}
	
	[self.adFlakeView adapterUserWatchedEntireVideoAdModal:self];
	[self helperNotifyDelegateOfFullScreenModalDismissal];
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
	[super dealloc];
}

@end

#endif
