/**
 * AdFlakeAdapterMillennial.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterMillennial.m
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

#if defined(AdFlake_Enable_SDK_MillennialMedia)

#import "AdFlakeAdapterMillennial.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#define kMillennialAdFrame (CGRectMake(0, 0, 320, 50))

@interface AdFlakeAdapterMillennial ()

- (NSNumber*)age;

- (NSString *)zipCode;

- (MMGender)gender;

@end


@implementation AdFlakeAdapterMillennial

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeMillennial;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
	NSString *apID;
	if ([adFlakeDelegate respondsToSelector:@selector(millennialMediaApIDString)]) {
		apID = [adFlakeDelegate millennialMediaApIDString];
	}
	else {
		apID = networkConfig.pubId;
	}


#if 0
	MMAdType adType = MMBannerAdTop;
	if ([adFlakeDelegate respondsToSelector:@selector(millennialMediaAdType)]) {
		adType = [adFlakeDelegate millennialMediaAdType];
	}
#endif

	CLLocation *loc = nil;

	if ([adFlakeDelegate respondsToSelector:@selector(locationInfo)])
	{
		loc = [adFlakeDelegate locationInfo];
	}

	MMRequest *request = nil;
	if (loc != nil)
	{
		request = [MMRequest requestWithLocation:loc];
	}
	else
	{
		request = [MMRequest request];
	}

	if ([self respondsToSelector:@selector(zipCode)]) {
		request.zipCode = [self zipCode];
	}
	if ([self respondsToSelector:@selector(age)]) {
		request.age = [self age];
	}
	if ([self respondsToSelector:@selector(gender)]) {
		request.gender = [self gender];
	}

	MMAdView *adView = [[MMAdView alloc] initWithFrame:kMillennialAdFrame
												  apid:apID
									rootViewController:[adFlakeDelegate viewControllerForPresentingModalView]];



	/*

	 MMAdView *adView = [MMAdView adWithFrame:kMillennialAdFrame
	 type:adType
	 apid:apID
	 delegate:self
	 loadAd:YES
	 startTimer:NO];

	 adView.rootViewController =
	 [adFlakeDelegate viewControllerForPresentingModalView];
	 */
	self.adNetworkView = adView;

	[adView getAdWithRequest:request onCompletion:^(BOOL success, NSError *error)
	 {
		 if (success) {
			 [self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
		 }
		 else {
			 [self.adFlakeView adapter:self didFailAd:error];
		 }
	 }];
}

- (void)stopBeingDelegate {
	//  MMAdView *adView = (MMAdView *)adNetworkView;
	//  if (adView != nil) {
	//    [adView setRefreshTimerEnabled:false];
	//    adView.delegate = nil;
	//  }
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark requestData optional methods

// The follow is kept for gathering requestData

- (BOOL)respondsToSelector:(SEL)selector {
	if (selector == @selector(latitude)
		&& ![adFlakeDelegate respondsToSelector:@selector(locationInfo)]) {
		return NO;
	}
	else if (selector == @selector(longitude)
			 && ![adFlakeDelegate respondsToSelector:@selector(locationInfo)]) {
		return NO;
	}
	else if (selector == @selector(age)
			 && (!([adFlakeDelegate respondsToSelector:@selector(dateOfBirth)])
				 || [self age] < 0)) {
				 return NO;
			 }
	else if (selector == @selector(zipCode)
			 && ![adFlakeDelegate respondsToSelector:@selector(postalCode)]) {
		return NO;
	}
	else if (selector == @selector(gender)
			 && ![adFlakeDelegate respondsToSelector:@selector(gender)]) {
		return NO;
	}
	else if (selector == @selector(householdIncome)
			 && ![adFlakeDelegate respondsToSelector:@selector(incomeLevel)]) {
		return NO;
	}
	else if (selector == @selector(educationLevel)
			 && ![adFlakeDelegate respondsToSelector:@selector(millennialMediaEducationLevel)]) {
		return NO;
	}
	else if (selector == @selector(ethnicity)
			 && ![adFlakeDelegate respondsToSelector:@selector(millennialMediaEthnicity)]) {
		return NO;
	}
	return [super respondsToSelector:selector];
}

- (NSNumber*)age {
	return [NSNumber numberWithInteger:[self helperCalculateAge]];
}

- (NSString *)zipCode {
	return [adFlakeDelegate postalCode];
}

- (MMGender)gender {
	NSString *sex = [adFlakeDelegate gender];
	MMGender mmgender = MMGenderOther;

	if (sex == nil)
		return MMGenderOther;

	if ([sex compare:@"m"] == NSOrderedSame) {
		mmgender = MMGenderMale;
	}
	else if ([sex compare:@"f"] == NSOrderedSame) {
		mmgender = MMGenderFemale;
	}
	return mmgender;
}

/*
 - (NSInteger)householdIncome {
 return (NSInteger)[adFlakeDelegate incomeLevel];
 }

 - (MMEducation)educationLevel {
 return [adFlakeDelegate millennialMediaEducationLevel];
 }

 - (MMEthnicity)ethnicity {
 return [adFlakeDelegate millennialMediaEthnicity];
 }
 */

@end

#endif
