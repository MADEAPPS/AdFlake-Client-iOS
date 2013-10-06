/**
 * AdFlakeConfigStore.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeConfigStore.h
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

#import <Foundation/Foundation.h>
#import "AdFlakeConfigStore.h"
#import "AdFlakeConfig.h"
#import "AFNetworkReachabilityWrapper.h"


// Singleton class to store AdFlake configs, keyed by appKey. Fetched config
// is cached unless it is force-fetched using fetchConfig. Checks network
// reachability using AFNetworkReachabilityWrapper before making connections to
// fetch configs, so that that means it will wait forever until the config host
// is reachable.
@interface AdFlakeConfigStore : NSObject <AFNetworkReachabilityDelegate> {
	NSMutableDictionary *configs_;
	AdFlakeConfig *fetchingConfig_;

	AFNetworkReachabilityWrapper *reachability_;
	NSURLConnection *connection_;
	NSMutableData *receivedData_;
}

// Returns the singleton AdFlakeConfigStore object.
+ (AdFlakeConfigStore *)sharedStore;

// Deletes all existing configs.
+ (void)resetStore;

// Returns config for appKey. If config does not exist for appKey, goes and
// fetches the config from the server, the URL of which is taken from
// [delegate adFlakeConfigURL].
// Returns nil if appKey is nil or empty, another fetch is in progress, or
// error setting up reachability check.
- (AdFlakeConfig *)getConfig:(NSString *)appKey
                    delegate:(id<AdFlakeConfigDelegate>)delegate;

// Fetches (or re-fetch) the config for the given appKey. Always go to the
// network. Call this to get a new version of the config from the server.
// Returns nil if appKey is nil or empty, another fetch is in progress, or
// error setting up reachability check.
- (AdFlakeConfig *)fetchConfig:(NSString *)appKey
                      delegate:(id <AdFlakeConfigDelegate>)delegate;

// For testing -- set mocks here.
@property (nonatomic,retain) AFNetworkReachabilityWrapper *reachability;
@property (nonatomic,retain) NSURLConnection *connection;

@end
