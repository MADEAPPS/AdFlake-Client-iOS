/**
 * AdFlakeAdapterJumpTap.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterJumpTap.m
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

#import "AdFlakeAdapterJumpTap.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeAdNetworkRegistry.h"


#import "AdFlakeConfiguration.h"

#if defined(AdFlake_Enable_SDK_JumpTap)

@implementation AdFlakeAdapterJumpTap

+ (AdFlakeAdNetworkType)networkType
{
	return AdFlakeAdNetworkTypeJumpTap;
}

+ (void)load
{
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
	static bool isSdkInitialized = false;

	if (!isSdkInitialized)
	{
		[JTAdWidget initializeAdService:self.adFlakeConfig.locationOn];
		isSdkInitialized = true;
	}

	JTAdWidget *widget = [[[JTAdWidget alloc] initWithDelegate:self
											shouldStartLoading:YES] autorelease];
	widget.frame = kAdFlakeViewDefaultFrame;
	widget.refreshInterval = 60; // do not self-refresh
	self.adNetworkView = widget;

	if ([adFlakeDelegate respondsToSelector:@selector(jumptapTransitionType)]) {
		widget.transition = [adFlakeDelegate jumptapTransitionType];
	}
}

- (void)stopBeingDelegate
{
	if (self.adNetworkView != nil)
	{
		JTAdWidget* widget = (JTAdWidget*)self.adNetworkView;
		[widget setDelegate:nil];
	}
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark JTAdWidgetDelegate methods

- (NSString *)publisherId:(id)theWidget
{
	NSString *pubId = networkConfig.pubId;
	if (pubId == nil) {
		NSDictionary *cred = networkConfig.credentials;
		if (cred != nil) {
			pubId = [cred objectForKey:@"publisherID"];
		}
	}
	return pubId;
}

- (NSString *)site:(id)theWidget
{
	NSString *siteId = nil;
	if ([adFlakeDelegate respondsToSelector:@selector(jumptapSiteId)]) {
		siteId = [adFlakeDelegate jumptapSiteId];
	}
	if (siteId == nil) {
		NSDictionary *cred = networkConfig.credentials;
		if (cred != nil) {
			siteId = [cred objectForKey:@"siteID"];

			if (siteId.length == 0)
				siteId = nil;
		}
	}
	return siteId;
}

- (NSString *)adSpot:(id)theWidget
{
	NSString *spotId = nil;
	if ([adFlakeDelegate respondsToSelector:@selector(jumptapSpotId)]) {
		spotId = [adFlakeDelegate jumptapSpotId];
	}
	if (spotId == nil) {
		NSDictionary *cred = networkConfig.credentials;
		if (cred != nil) {
			spotId = [cred objectForKey:@"spotID"];

			if (spotId.length == 0)
				spotId = nil;
		}
	}
	return spotId;
}

- (BOOL)shouldRenderAd:(id)theWidget
{
	[adFlakeView adapter:self didReceiveAdView:theWidget];
	return YES;
}

- (void)beginAdInteraction:(id)theWidget
{
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)endAdInteraction:(id)theWidget
{
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void)adWidget:(id)theWidget didFailToShowAd:(NSError *)error
{
	[adFlakeView adapter:self didFailAd:error];
}

- (void)adWidget:(id)theWidget didFailToRequestAd:(NSError *)error
{
	[adFlakeView adapter:self didFailAd:error];
}

- (BOOL)respondsToSelector:(SEL)selector
{
	if (selector == @selector(location:)
		&& ![adFlakeDelegate respondsToSelector:@selector(locationInfo)]) {
		return NO;
	}
	else if (selector == @selector(query:)
			 && ![adFlakeDelegate respondsToSelector:@selector(keywords)]) {
		return NO;
	}
	else if (selector == @selector(category:)
			 && ![adFlakeDelegate respondsToSelector:@selector(jumptapCategory)]) {
		return NO;
	}
	else if (selector == @selector(adultContent:)
			 && ![adFlakeDelegate respondsToSelector:@selector(jumptapAdultContent)]) {
		return NO;
	}
	return [super respondsToSelector:selector];
}

#pragma mark JTAdWidgetDelegate methods -Targeting

- (NSString *)query:(id)theWidget
{
	return [adFlakeDelegate keywords];
}

- (NSString *)category:(id)theWidget
{
	return [adFlakeDelegate jumptapCategory];
}

- (AdultContent)adultContent:(id)theWidget
{
	return [adFlakeDelegate jumptapAdultContent];
}

#pragma mark JTAdWidgetDelegate methods -General Configuration

- (NSDictionary*)extraParameters:(id)theWidget {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	if ([adFlakeDelegate respondsToSelector:@selector(dateOfBirth)]) {
		NSInteger age = [self helperCalculateAge];
		if (age >= 0)
			[dict setObject:[NSString stringWithFormat:@"%d",age] forKey:@"mt-age"];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(gender)]) {
		NSString *gender = [adFlakeDelegate gender];
		if (gender != nil)
			[dict setObject:gender forKey:@"mt-gender"];
	}
	if ([adFlakeDelegate respondsToSelector:@selector(incomeLevel)]) {
		NSUInteger income = [adFlakeDelegate incomeLevel];
		NSString *level = nil;
		if (income < 15000) {
			level = @"000_015";
		}
		else if (income < 20000) {
			level = @"015_020";
		}
		else if (income < 30000) {
			level = @"020_030";
		}
		else if (income < 40000) {
			level = @"030_040";
		}
		else if (income < 50000) {
			level = @"040_050";
		}
		else if (income < 75000) {
			level = @"050_075";
		}
		else if (income < 100000) {
			level = @"075_100";
		}
		else if (income < 125000) {
			level = @"100_125";
		}
		else if (income < 150000) {
			level = @"125_150";
		}
		else {
			level = @"150_OVER";
		}
		[dict setObject:level forKey:@"mt-hhi"];
	}
	return dict;
}

- (UIColor *)adBackgroundColor:(id)theWidget {
	return [self helperBackgroundColorToUse];
}

- (UIColor *)adForegroundColor:(id)theWidget {
	return [self helperTextColorToUse];
}

#pragma mark JTAdWidgetDelegate methods -Location Configuration

- (BOOL)allowLocationUse:(id)theWidget {
	return adFlakeConfig.locationOn;
}

- (CLLocation*)location:(id)theWidget {
	if (![adFlakeDelegate respondsToSelector:@selector(locationInfo)]) {
		return nil;
	}
	return [adFlakeDelegate locationInfo];
}

#pragma mark JTAdWidgetDelegate methods -Ad Display and User Interaction
// The ad orientation changed
//- (void)adWidget:(id)theWidget orientationHasChangedTo:(UIInterfaceOrientation)interfaceOrientation;

// Language methods
//- (NSString*)getPlayVideoPrompt:(id)theWidget;
//- (NSString*)getBackButtonPrompt:(id)theWidget isInterstitial:(BOOL)isInterstitial;
//- (NSString*)getSafariButtonPrompt:(id)theWidget;

@end

#endif