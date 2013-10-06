/**
 * AdFlakeAdNetworkAdapter.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdNetworkAdapter.m
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

#import "AdFlakeAdNetworkAdapter.h"
#import "AdFlakeView.h"
#import "AdFlakeView+Internal.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

@implementation AdFlakeAdNetworkAdapter

@synthesize adFlakeDelegate;
@synthesize adFlakeView;
@synthesize adFlakeConfig;
@synthesize networkConfig;
@synthesize adNetworkView;

- (id)initWithAdFlakeDelegate:(id<AdFlakeDelegate>)delegate
                         view:(AdFlakeView *)view
                       config:(AdFlakeConfig *)config
                networkConfig:(AdFlakeAdNetworkConfig *)netConf {
	self = [super init];
	if (self != nil) {
		self.adFlakeDelegate = delegate;
		self.adFlakeView = view;
		self.adFlakeConfig = config;
		self.networkConfig = netConf;
	}
	return self;
}

- (void)getAd {
	AFLogCrit(@"Subclass of AdFlakeAdNetworkAdapter must implement -getAd.");
	[self doesNotRecognizeSelector:_cmd];
}

- (void)stopBeingDelegate {
	AFLogCrit(@"Subclass of AdFlakeAdNetworkAdapter must implement -stopBeingDelegate.");
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL)shouldSendExMetric {
	return YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
	// do nothing by default. Subclasses implement specific handling.
	AFLogDebug(@"rotate to orientation %d called for adapter %@",
			   orientation, NSStringFromClass([self class]));
}

- (BOOL)isBannerAnimationOK:(AFBannerAnimationType)animType {
	return YES;
}

- (void)dealloc {
	[self stopBeingDelegate];
	adFlakeDelegate = nil;
	adFlakeView = nil;
	[adFlakeConfig release], adFlakeConfig = nil;
	[networkConfig release], networkConfig = nil;
	[adNetworkView release], adNetworkView = nil;
	[super dealloc];
}

@end


@implementation AdFlakeAdNetworkAdapter (Helpers)

- (void)helperNotifyDelegateOfFullScreenModal {
	// don't request new ad when modal view is on
	adFlakeView.showingModalView = YES;
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeWillPresentFullScreenModal)]) {
		[adFlakeDelegate adFlakeWillPresentFullScreenModal];
	}
}

- (void)helperNotifyDelegateOfFullScreenModalDismissal {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeDidDismissFullScreenModal)]) {
		[adFlakeDelegate adFlakeDidDismissFullScreenModal];
	}
	adFlakeView.showingModalView = NO;
}

- (UIColor *)helperBackgroundColorToUse {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeAdBackgroundColor)]) {
		UIColor *color = [adFlakeDelegate adFlakeAdBackgroundColor];
		if (color != nil) return color;
	}
	return adFlakeConfig.backgroundColor;
}

- (UIColor *)helperTextColorToUse {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTextColor)]) {
		UIColor *color = [adFlakeDelegate adFlakeTextColor];
		if (color != nil) return color;
	}
	return adFlakeConfig.textColor;
}

- (UIColor *)helperSecondaryTextColorToUse {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeSecondaryTextColor)]) {
		UIColor *color = [adFlakeDelegate adFlakeSecondaryTextColor];
		if (color != nil) return color;
	}
	return nil;
}

- (NSInteger)helperCalculateAge {
	NSDate *birth = [adFlakeDelegate dateOfBirth];
	if (birth == nil) {
		return -1;
	}
	NSDate *today = [[NSDate alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit
												fromDate:birth
												  toDate:today
												 options:0];
	NSInteger years = [components year];
	[gregorian release];
	[today release];
	return years;
}

- (NSObject *)helperDelegateValueForSelector:(SEL)selector {
	return ([adFlakeDelegate respondsToSelector:selector]) ?
	[adFlakeDelegate performSelector:selector] : nil;
}

- (bool)helperUseTestAds
{
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
		return [adFlakeDelegate adFlakeTestMode];
	return NO;
}

@end
