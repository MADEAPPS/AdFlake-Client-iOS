/**
 * AdFlakeAdapterSayMedia.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterSayMedia.m
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

#if defined(AdFlake_Enable_SDK_SayMedia)

#import "AdFlakeAdapterSayMedia.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFrameView.h"
#import "AdFlakeLog.h"
#import "AdFlakeAdNetworkAdapter+Helpers.h"
#import "AdFlakeAdNetworkRegistry.h"

@interface AdFlakeAdapterSayMedia ()

- (void)loadSuccess:(NSNotification *)notification;
- (void)loadFailed:(NSNotification *)notification;
- (void)launchAd:(NSNotification *)notification;
- (void)closeAd:(NSNotification *)notification;

@end


@implementation AdFlakeAdapterSayMedia

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeVideoEgg;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
	AdFrameView *aw = [[AdFrameView alloc] init];

	NSDictionary *credentials = [networkConfig credentials];
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeTestMode)]
		&& [adFlakeDelegate adFlakeTestMode]) {
		credentials = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"testpublisher", @"publisher",
					   @"testarea", @"area",
					   nil];
	}
	else if ([adFlakeDelegate respondsToSelector:@selector(sayMediaConfigDictionary)]) {
		credentials = [adFlakeDelegate sayMediaConfigDictionary];
	}

	NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
	[notifCenter addObserver:self
					selector:@selector(loadSuccess:)
						name:kVELoadSuccess
					  object:aw];
	[notifCenter addObserver:self
					selector:@selector(loadFailed:)
						name:kVELoadFailure
					  object:aw];
	[notifCenter addObserver:self
					selector:@selector(launchAd:)
						name:kVELaunchedAd
					  object:aw];
	[notifCenter addObserver:self
					selector:@selector(closeAd:)
						name:kVEClosedAd
					  object:aw];

	VEConfig *config = [VEConfig dictionaryWithDictionary:credentials];
	[aw requestAd:config];
	self.adNetworkView = aw;
	[aw release];
}

- (void)stopBeingDelegate {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark VideoEgg notification methods

- (void)loadSuccess:(NSNotification *)notification {
	CGRect frame = CGRectMake(0,0,ADFRAME_BANNER_WIDTH, ADFRAME_BANNER_HEIGHT);
	adNetworkView.frame = frame;
	[adFlakeView adapter:self didReceiveAdView:adNetworkView];
}

- (void)loadFailed:(NSNotification *)notification {
	[adFlakeView adapter:self didFailAd:nil];
}

- (void)launchAd:(NSNotification *)notification {
	[self helperNotifyDelegateOfFullScreenModal];
}

- (void)closeAd:(NSNotification *)notification {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end

#endif
