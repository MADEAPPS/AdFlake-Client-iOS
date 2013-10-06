/**
 * AdFlakeAdapterMdotM.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterMdotM.m
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

#if defined(AdFlake_Enable_SDK_MdotM)

#import "AdFlakeAdapterMdotM.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"
#import "AdFlakeAdapterCustom.h"
#import "CJSONDeserializer.h"
#import "AdFlakeCustomAdView.h"

#import "MdotMAdSizes.h"
#import "MdotMInterstitial.h"
#import "MdotMInterstitialDelegate.h"
#import "MdotMAdView.h"
#import "MdotMAdViewDelegate.h"
#import "MdotMRequestParameters.h"

@interface AdFlakeAdapterMdotM ()


@end


@implementation AdFlakeAdapterMdotM


+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeMdotM;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (BOOL)useTestAd {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)])
		return [adFlakeDelegate adFlakeTestMode];
	return NO;
}


- (void)getAd {
	NSString *appKey = networkConfig.pubId;

	if ([adFlakeDelegate respondsToSelector:@selector(MdotMApplicationKey)] ) {
		appKey = [adFlakeDelegate MdotMApplicationKey];
	}

	MdotMAdView *adview = [[[MdotMAdView alloc] initWithFrame:CGRectMake (0,0, 320, 50)] autorelease];
	adview.adViewDelegate = self;

	self.adNetworkView = adview;

	MdotMRequestParameters *requestParameters = [[[MdotMRequestParameters alloc]init] autorelease];
	requestParameters.appKey = appKey;
	requestParameters.test = [self useTestAd] ? @"1" : @"0";

	[adview loadBannerAd:requestParameters withSize:BANNER_320_50];
}


#pragma mark MdotMDelegate

-(void)onReceiveBannerAd
{
	[self.adFlakeView adapter:self didReceiveAdView:self.adNetworkView];
}

-(void)onReceiveBannerAdError:(NSString *)error
{
	[self.adFlakeView adapter:self didFailAd:[NSError errorWithDomain:error code:0 userInfo:[NSDictionary dictionary]]];
}


#pragma mark MdotMDelegate optional methods

- (BOOL)respondsToSelector:(SEL)selector {
	if (selector == @selector(location)
		&& ![adFlakeDelegate respondsToSelector:@selector(location)]) {
		return NO;
	}
	else if (selector == @selector(userContext)
			 && ![adFlakeDelegate respondsToSelector:@selector(userContext)]) {
		return NO;
	}  return [super respondsToSelector:selector];
}

- (void)stopBeingDelegate {
    MdotMAdView *theAdView = (MdotMAdView *)self.adNetworkView;
    if (theAdView != nil) {
        theAdView.adViewDelegate = nil;
    }
}

- (void)dealloc {
	[super dealloc];
}

@end

#endif