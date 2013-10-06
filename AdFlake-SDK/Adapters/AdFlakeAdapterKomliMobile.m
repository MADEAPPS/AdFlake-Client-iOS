/**
 * AdFlakeAdapterKomliMobile.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterKomliMobile.m
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

#if defined(AdFlake_Enable_SDK_KomliMobile)

#import "AdFlakeAdapterKomliMobile.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "komlimobileAdzView.h"

@implementation AdFlakeAdapterKomliMobile

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeKomliMobile;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
	komlimobileAdzView *komliView = [[[komlimobileAdzView alloc] initWithFrame:kAdFlakeViewDefaultFrame Delegate:self] autorelease];

	self.adNetworkView = komliView;
}

- (void)stopBeingDelegate {
	// no way to set zestView's delegate to nil
}

- (void)dealloc {
	[super dealloc];
}

- (BOOL)useTestAd {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
		return [adFlakeDelegate adFlakeTestMode];
	return NO;
}

#pragma mark ZestadzDelegate required methods.

- (NSString *)adDevelopmentMode
{
	if ([self useTestAd])
		return @"development";

	return @"live";
}


- (double)adRefreshTime
{
	return 1.0f;
}

- (int) adRequestTimeOut
{
	return 1;
}

- (NSString *)clientId
{
	if ([self useTestAd])
	{
		return  @"14131C047A504040405D415244584A5C888123CC";
	}

	if ([adFlakeDelegate respondsToSelector:@selector(komliMobileClientID)]) {
		return [adFlakeDelegate komliMobileClientID];
	}
	return networkConfig.pubId;
}

- (UIViewController *)currentViewController {
	return [adFlakeDelegate viewControllerForPresentingModalView];
}

#pragma mark ZestadzDelegate notification methods

- (void)didReceiveAd:(ZestadzView *)adView {
	[self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)didFailToReceiveAd:(ZestadzView *)adView {
	[adFlakeView adapter:self didFailAd:nil];
}

- (void)willPresentFullScreenModal {
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)didDismissFullScreenModal {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

#pragma mark ZestadzDelegate config methods


- (NSString *) adType {
    return @"text+picture";
}

- (definedAdSize) adSize {
    return ADSIZE320x50;
}

- (definedAdRMASupport) adRMAType {
    return RMA_SUPPORT;
}

- (UIColor *)adBackgroundColor {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeAdBackgroundColor)]) {
		return [adFlakeDelegate adFlakeAdBackgroundColor];
	}

    return nil;
}

-(UIColor *)adFontColor
{
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTextColor)]) {
		return [adFlakeDelegate adFlakeTextColor];
	}

    return nil;
}

- (NSString *)keywords {
	if ([adFlakeDelegate respondsToSelector:@selector(keywords)]) {
		return [adFlakeDelegate keywords];
	}

	return @"iphone ipad ipod";
}

@end

#endif

