/**
 * AdFlakeAdapterGreystripe.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterGreystripe.m
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

#if defined(AdFlake_Enable_SDK_GreyStripe)

#import "AdFlakeAdapterGreystripe.h"

#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeAdNetworkRegistry.h"
#import "AdFlakeCommon.h"
#import "AdFlakeView.h"

#import "GSSDKInfo.h"
#import "GSAd.h"
#import "GSAdDelegate.h"
#import "GSBannerAdView.h"
#import "GSMobileBannerAdView.h"
#import "GSFullscreenAd.h"


@interface AdFlakeAdapterGreystripe ()
@end

@implementation AdFlakeAdapterGreystripe

@synthesize fullscreenAd = _fullscreenAd;

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeGreyStripe;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (BOOL)useFullScreenAd
{
	if ([adFlakeDelegate respondsToSelector:@selector(greystripeShouldDisplayFullScreenAd)])
	{
		return [adFlakeDelegate greystripeShouldDisplayFullScreenAd];
	}

	return NO;
}

- (void)getAd
{
	CLLocation *location = (CLLocation *)[self helperDelegateValueForSelector:@selector(locationInfo)];
	if ((adFlakeConfig.locationOn) && (location)) {
		[GSSDKInfo updateLocation:location];
	}

	self.fullscreenAd = nil;
	self.adNetworkView = nil;

	if ([self useFullScreenAd])
	{
		GSFullscreenAd *gsFullscreenAd = [[[GSFullscreenAd alloc] initWithDelegate:self] autorelease];

		self.fullscreenAd = gsFullscreenAd;

		[gsFullscreenAd fetch];
	}
	else
	{
		GSMobileBannerAdView *gsAdView = [[[GSMobileBannerAdView alloc] initWithDelegate:self] autorelease];
		CGRect bannerFrame = CGRectMake(0, 0, kGSMobileBannerWidth, kGSMobileBannerHeight);
		[gsAdView setFrame:bannerFrame];
		self.adNetworkView = gsAdView;

		[gsAdView fetch];
	}
}

- (void)stopBeingDelegate {
	if (self.adNetworkView != nil)
	{
		GSMobileBannerAdView *gsBanner = (GSMobileBannerAdView*)self.adNetworkView;
		gsBanner.delegate = nil;
	}
}

- (void)dealloc {
	self.fullscreenAd = nil;

	[super dealloc];
}

#pragma mark - GreystripeDelegate notification methods

- (NSString *)greystripeGUID
{
	return self.networkConfig.pubId;
}

- (BOOL)greystripeShouldLogAdID
{
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
		return [adFlakeDelegate adFlakeTestMode];

	return NO;
}

- (BOOL)greystripeBannerAutoload
{
    return FALSE;
}

- (UIViewController *)greystripeBannerDisplayViewController
{
	return [adFlakeDelegate viewControllerForPresentingModalView];
}

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
	if (self.fullscreenAd != nil &&
		self.fullscreenAd == a_ad)
	{
		[self.adFlakeView adapter:self didReceiveAdView:nil];
		[self.fullscreenAd displayFromViewController:[self greystripeBannerDisplayViewController]];
		return;
	}

	[self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
}


- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error {
    NSString *errorString =  @"";

    switch(a_error) {
        case kGSNoNetwork:
            errorString = @"No network connection available.";
            break;
        case kGSNoAd:
            errorString = @"No ad available from server.";
            break;
        case kGSTimeout:
            errorString = @"Fetch request timed out.";
            break;
        case kGSServerError:
            errorString = @"Greystripe returned a server error.";
            break;
        case kGSInvalidApplicationIdentifier:
            errorString = @"Invalid or missing application identifier.";
            break;
        case kGSAdExpired:
            errorString = @"Previously fetched ad expired.";
            break;
        case kGSFetchLimitExceeded:
            errorString = @"Too many requests too quickly.";
            break;
        case kGSUnknown:
            errorString = @"An unknown error has occurred.";
            break;
        default:
            errorString = @"An invalid error code was returned. Thats really bad!";
    }
	[self.adFlakeView adapter:self didFailAd:[NSError errorWithDomain:errorString code:a_error userInfo:[NSDictionary dictionary]]];
}


- (void)greystripeWillPresentModalViewController
{
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)greystripeWillDismissModalViewController
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void)greystripeDidDismissModalViewController
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void)greystripeBannerWillExpand
{
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)greystripeBannerDidCollapse
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}


@end

#endif