/**
 * AdFlakeAdapterGeneric.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterGeneric.m
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

#import "AdFlakeAdapterGeneric.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

@implementation AdFlakeAdapterGeneric

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeGeneric;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
	if ([adFlakeDelegate respondsToSelector:@selector(adFlakeReceivedRequestForDeveloperToFufill:)]) {
		[adFlakeDelegate adFlakeReceivedRequestForDeveloperToFufill:adFlakeView];
		[adFlakeView adapterDidFinishAdRequest:self];
	}
	else {
		AFLogWarn(@"Delegate does not implement adFlakeReceivedRequestForDeveloperToFufill");
		[adFlakeView adapter:self didFailAd:nil];
	}
}

- (void)stopBeingDelegate {
	// nothing to do
}

- (void)dealloc {
	[super dealloc];
}

@end
