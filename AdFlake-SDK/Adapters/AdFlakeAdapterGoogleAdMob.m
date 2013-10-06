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

#import "AdFlakeAdapterGoogleAdMob.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "GADBannerView.h"

@implementation AdFlakeAdapterGoogleAdMob

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeAdMob;
}

- (NSString *)hexStringFromUIColor:(UIColor *)color
{
    // converts UIColor to hex string, ignoring alpha.
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    
	if (colorSpaceModel == kCGColorSpaceModelRGB || colorSpaceModel == kCGColorSpaceModelMonochrome)
    {
		const CGFloat *colors = CGColorGetComponents(color.CGColor);
		CGFloat red = 0.0, green = 0.0, blue = 0.0;
        
		if (colorSpaceModel == kCGColorSpaceModelRGB)
        {
			red = colors[0];
			green = colors[1];
			blue = colors[2];
			// we ignore alpha here.
		}
        else if (colorSpaceModel == kCGColorSpaceModelMonochrome)
        {
			red = green = blue = colors[0];
		}
		return [NSString stringWithFormat:@"%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
	}
	return nil;
}

- (void)getAd
{
	GADRequest *request = [GADRequest request];
    
	NSObject *value;

	NSMutableDictionary *additional = [NSMutableDictionary dictionary];
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		request.testing = YES;
	}

	if ((value = [self helperDelegateValueForSelector:@selector(adFlakeAdBackgroundColor)])) {
		[additional setObject:[self hexStringFromUIColor:(UIColor *)value]
					   forKey:@"color_bg"];
	}

	if ((value = [self helperDelegateValueForSelector:@selector(adFlakeAdBackgroundColor)])) {
		[additional setObject:[self hexStringFromUIColor:(UIColor *)value]
					   forKey:@"color_text"];
	}

	// deliberately don't allow other color specifications.

	if ([additional count] > 0) {
		request.additionalParameters = additional;
	}

	CLLocation *location = (CLLocation *)[self helperDelegateValueForSelector:@selector(locationInfo)];

	if ((adFlakeConfig.locationOn) && (location)) {
		[request setLocationWithLatitude:location.coordinate.latitude
							   longitude:location.coordinate.longitude
								accuracy:location.horizontalAccuracy];
	}

	NSString *string = (NSString *)[self helperDelegateValueForSelector:@selector(gender)];

	if ([string isEqualToString:@"m"]) {
		request.gender = kGADGenderMale;
	} else if ([string isEqualToString:@"f"]) {
		request.gender = kGADGenderFemale;
	} else {
		request.gender = kGADGenderUnknown;
	}

	if ((value = [self helperDelegateValueForSelector:@selector(dateOfBirth)])) {
		request.birthday = (NSDate *)value;
	}

	if ((value = [self helperDelegateValueForSelector:@selector(keywords)])) {
		NSArray *keywordArray =
        [(NSString *)value componentsSeparatedByString:@" "];
		request.keywords = [NSMutableArray arrayWithArray:keywordArray];
	}

	// Set the frame for this view to match the bounds of the parent adFlakeView.
	GADBannerView *view = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];

	view.adUnitID = [self publisherId];
	view.delegate = self;
	view.rootViewController = [adFlakeDelegate viewControllerForPresentingModalView];

	self.adNetworkView = (id)[view autorelease];

	[view loadRequest:request];
}

- (void)stopBeingDelegate
{
	if (self.adNetworkView != nil
		&& [self.adNetworkView respondsToSelector:@selector(setDelegate:)]) {
		[self.adNetworkView performSelector:@selector(setDelegate:)
								 withObject:nil];
	}
}

#pragma mark Ad Request Lifecycle Notifications

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
	[adFlakeView adapter:self didReceiveAdView:adView];
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
	[adFlakeView adapter:self didFailAd:error];
}

#pragma mark Click-Time Lifecycle Notifications

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

#pragma mark parameter gathering methods

- (NSString *)publisherId
{
	if (([adFlakeDelegate respondsToSelector:@selector(admobPublisherID)])) {
		return [adFlakeDelegate performSelector:@selector(admobPublisherID)];
	}

	return networkConfig.pubId;
}

@end

#endif
