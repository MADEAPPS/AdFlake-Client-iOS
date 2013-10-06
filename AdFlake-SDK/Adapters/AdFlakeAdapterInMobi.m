/**
 * AdFlakeAdapterInMobi.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterInMobi.m
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

#if defined(AdFlake_Enable_SDK_InMobi)

#import "AdFlakeAdapterInMobi.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "InMobi.h"
#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"
#import "IMError.h"
#import "IMNetworkExtras.h"
#import "IMInMobiNetworkExtras.h"
#import "InMobiAnalytics.h"

@implementation AdFlakeAdapterInMobi

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeInMobi;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
	[InMobi initialize:[self siteId]];

	IMBanner *inMobiView = [[[IMBanner alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
													  appId:[self siteId]
													 adSize:IM_UNIT_320x50] autorelease];


	inMobiView.refreshInterval = REFRESH_INTERVAL_OFF;
	inMobiView.delegate = self;
	self.adNetworkView = inMobiView;

	//	if ([self testMode]) {
	//		request.testMode = true;
	//	}
	if ([adFlakeDelegate respondsToSelector:@selector(postalCode)]) {
		[InMobi setPostalCode:[adFlakeDelegate postalCode]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(areaCode)]) {
		[InMobi setPostalCode:[adFlakeDelegate areaCode]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(dateOfBirth)]) {
		[InMobi setDateOfBirth:[adFlakeDelegate dateOfBirth]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(gender)]) {
		[InMobi setGender:[self gender]];
	}
	//	if ([adFlakeDelegate respondsToSelector:@selector(keywords)]) {
	//		request.keywords = [adFlakeDelegate keywords];
	//	}
	//	if ([adFlakeDelegate respondsToSelector:@selector(searchString)]) {
	//		request.searchString = [adFlakeDelegate searchString];
	//	}
	if ([adFlakeDelegate respondsToSelector:@selector(incomeLevel)]) {
		[InMobi setIncome:[adFlakeDelegate incomeLevel]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(inMobiEducation)]) {
		[InMobi setEducation:[adFlakeDelegate inMobiEducation]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(inMobiEthnicity)]) {
		[InMobi setEthnicity:[adFlakeDelegate inMobiEthnicity]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(dateOfBirth)]) {
		[InMobi setAge:[self helperCalculateAge]];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(inMobiInterests)]) {
		[InMobi setInterests:[adFlakeDelegate inMobiInterests]];
	}
	//	if ([adFlakeDelegate respondsToSelector:@selector(inMobiParamsDictionary)]) {
	//		request.paramsDictionary = [adFlakeDelegate inMobiParamsDictionary];
	//	}
	if (adFlakeConfig.locationOn) {
		CLLocation *location =
        (CLLocation *)[self
                       helperDelegateValueForSelector:@selector(locationInfo)];
		if (location) {
			[InMobi setLocationWithLatitude:location.coordinate.latitude
								  longitude:location.coordinate.longitude
								   accuracy:location.horizontalAccuracy];
		}
	}

	[inMobiView loadBanner];
}

- (void)stopBeingDelegate {
	IMBanner *inMobiView = (IMBanner *)self.adNetworkView;
	if (inMobiView != nil) {
		[inMobiView setDelegate:nil];
	}
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark IMAdView helper methods

- (NSString *)siteId {
	if ([adFlakeDelegate respondsToSelector:@selector(inMobiAppId)]) {
		return [adFlakeDelegate inMobiAppID];
	}
	return networkConfig.pubId;
}

- (UIViewController *)rootViewControllerForAd {
	return [adFlakeDelegate viewControllerForPresentingModalView];
}

- (BOOL)testMode {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
		return [adFlakeDelegate adFlakeTestMode];
	return NO;
}

- (IMGender)gender {
	if ([adFlakeDelegate respondsToSelector:@selector(gender)]) {
		NSString *genderStr = [adFlakeDelegate gender];
		if ([genderStr isEqualToString:@"f"]) {
			return kIMGenderFemale;
		} else if ([genderStr isEqualToString:@"m"]) {
			return kIMGenderMale;
		}
	}
	return kIMGenderNone;
}

#pragma mark IMAdDelegate methods


- (void)bannerDidReceiveAd:(IMBanner *)banner
{
	[self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error
{
	[self.adFlakeView adapter:self didFailAd:error];
}

#pragma mark Banner Interaction Notifications

-(void)bannerDidInteract:(IMBanner *)banner withParams:(NSDictionary *)dictionary
{
}

- (void)bannerWillPresentScreen:(IMBanner *)banner
{
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)bannerWillDismissScreen:(IMBanner *)banner
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void)bannerDidDismissScreen:(IMBanner *)banner
{
}

- (void)bannerWillLeaveApplication:(IMBanner *)banner
{
	[self helperNotifyDelegateOfFullScreenModal];
}

@end

#endif