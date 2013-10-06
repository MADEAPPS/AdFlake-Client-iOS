/**
 * AdFlakeAdapterNexage.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterNexage.m
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

#if defined(AdFlake_Enable_SDK_Nexage)

#import "AdFlakeAdapterNexage.h"
#import "AdFlakeAdNetworkAdapter+Helpers.h"
#import "AdFlakeAdNetworkRegistry.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "NexageAdViewController.h"
#import "NexageAdParameters.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeError.h"

@implementation AdFlakeAdapterNexage

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeNexage;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd{
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
						  [self dateOfBirth], @"u(dob)",
						  [self country], @"u(country)",
						  [self city], @"u(city)",
						  [self designatedMarketArea], @"u(dma)",
						  [self ethnicity], @"u(eth)",
						  [self gender], @"u(gender)",
						  [NSNumber numberWithDouble:[self houseIncome]], @"u(hhi)",
						  [self keywords], @"u(keywords)",
						  [self maritalStatus], @"u(marital)",
						  [self postCode], @"u(zip)",
						  nil];

	NSDictionary* credDict;
	if ([adFlakeDelegate respondsToSelector:@selector(nexageDictionary)]) {
		credDict = [adFlakeDelegate nexageDictionary];
	}
	else {
		credDict = [networkConfig credentials];
	}

	BOOL testMode = NO;
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		testMode = YES;
	}

	// Nexage does weird things with position which can result in an over-release,
	// so we're basically forced to leak this...
	position = [[credDict objectForKey:@"position"] copy];
	if(position == nil){
		[adFlakeView adapter:self didFailAd:nil];
		return;
	}

	adViewController =
	[[NexageAdViewController alloc] initWithDelegate:position delegate:self];
	[adViewController setEnable:YES];


	[adViewController setAttributes:atts];
	[adViewController setTestMode:testMode];
	[adViewController locationAware:adFlakeConfig.locationOn];
#ifdef ADFLAKE_DEBUG
	[adViewController enableLogging:YES];
#endif
	self.adNetworkView = adViewController.view;
}

- (void)stopBeingDelegate {
	if (adViewController != nil) {
		adViewController.delegate = nil;
	}
}

- (void)dealloc {
	[self stopBeingDelegate];
	[adViewController setAttributes:nil];
	[adViewController release];
	adViewController = nil;
	[super dealloc];
}

#pragma mark NexageDelegateProtocol

- (void)adReceived:(UIView *)ad {
	[adFlakeView adapter:self didReceiveAdView:ad];
}
/**
 * This method will be called when user clicks the ad banner.
 * The URL is an optional parameter, if Ad is from the Nexage mediation
 * platform, you will get validate url, if it is nil, that means the action
 * is from integrated sdk. Please check if (url == nil). The return YES, means
 * the sdk will handle click event, otherwise sdk will ignore the user action.
 * Basic Ad network principle should always return YES. Please refer our dev
 * document for details
 */
- (BOOL)adActionShouldBegin:(NSURLRequest *)request
       willLeaveApplication:(BOOL)willLeave {
	[self helperNotifyDelegateOfFullScreenModal];
	return YES;
}

/**
 * The delegate will be called when full screen web browser is closed
 */
- (void)adFullScreenWebBrowserWillClose {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}
/**
 * identify the ad did not receive at this momnent.
 */
- (void)didFailToReceiveAd {
	[adFlakeView adapter:self didFailAd:nil];
}

- (NSString *)dcnForAd {
	NSDictionary *credDict;
	if ([adFlakeDelegate respondsToSelector:@selector(nexageDictionary)]) {
		credDict = [adFlakeDelegate nexageDictionary];
	}
	else {
		credDict = [networkConfig credentials];
	}
	return [credDict objectForKey:@"dcn"];
}

- (UIViewController*)currentViewController {
	return [adFlakeDelegate viewControllerForPresentingModalView];
}

#pragma mark user profiles

- (NSDate *)dateOfBirth {
	if([adFlakeDelegate respondsToSelector:@selector(dateOfBirth)])
    return [adFlakeDelegate dateOfBirth];
	return nil;
}

- (NSString *)postCode {
	if([adFlakeDelegate respondsToSelector:@selector(postalCode)])
    return [adFlakeDelegate postalCode];
	else return nil;
}

- (NSString *)gender {
	if([adFlakeDelegate respondsToSelector:@selector(gender)])
    return [adFlakeDelegate gender];
	else return nil;
}

- (NSString *)keywords {
	if([adFlakeDelegate respondsToSelector:@selector(keywords)])
    return [adFlakeDelegate keywords];
	else return nil;
}

- (NSInteger)houseIncome {
	if([adFlakeDelegate respondsToSelector:@selector(incomeLevel)])
    return [adFlakeDelegate incomeLevel];
	return 0;
}

- (NSString *)city {
	if([adFlakeDelegate respondsToSelector:@selector(nexageCity)])
    return [adFlakeDelegate nexageCity];
	else return nil;
}

- (NSString *)designatedMarketArea {
	if([adFlakeDelegate respondsToSelector:@selector(nexageDesignatedMarketArea)])
    return [adFlakeDelegate nexageDesignatedMarketArea];
	else return nil;
}

- (NSString *)country {
	if([adFlakeDelegate respondsToSelector:@selector(nexageCountry)])
    return [adFlakeDelegate nexageCountry];
	else return nil;
}

- (NSString *)ethnicity {
	if([adFlakeDelegate respondsToSelector:@selector(nexageEthnicity)])
    return [adFlakeDelegate nexageEthnicity];
	else return nil;
}

- (NSString *)maritalStatus {
	if([adFlakeDelegate respondsToSelector:@selector(nexageMaritalStatus)])
    return [adFlakeDelegate nexageMaritalStatus];
	else return nil;
}

- (NSString *)areaCode {
	if([adFlakeDelegate respondsToSelector:@selector(areaCode)])
    return [adFlakeDelegate areaCode];
	else return nil;
}
@end

#endif