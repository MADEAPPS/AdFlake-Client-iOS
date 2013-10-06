/**
 * AdFlakeConfigStore.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeConfigStore.m
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

#import "AdFlakeConfigStore.h"
#import "AdFlakeCommon.h"
#import "AFNetworkReachabilityWrapper.h"

static AdFlakeConfigStore *gStore = nil;

@interface AdFlakeConfigStore ()

- (BOOL)checkReachability;
- (void)startFetchingAssumingReachable;
- (void)failedFetchingWithError:(AdFlakeError *)error;
- (void)finishedFetching;

@end


@implementation AdFlakeConfigStore

@synthesize reachability = reachability_;
@synthesize connection = connection_;

+ (AdFlakeConfigStore *)sharedStore {
	if (gStore == nil) {
		gStore = [[AdFlakeConfigStore alloc] init];
	}
	return gStore;
}

+ (void)resetStore {
	if (gStore != nil) {
		[gStore release], gStore = nil;
		[self sharedStore];
	}
}

- (id)init {
	self = [super init];
	if (self != nil) {
		configs_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (AdFlakeConfig *)getConfig:(NSString *)appKey
                    delegate:(id<AdFlakeConfigDelegate>)delegate {
	AdFlakeConfig *config = [configs_ objectForKey:appKey];
	if (config != nil) {
		if (config.hasConfig) {
			if ([delegate
				 respondsToSelector:@selector(adFlakeConfigDidReceiveConfig:)]) {
				// Don't call directly, instead schedule it in the runloop. Delegate
				// may expect the message to be delivered out-of-band
				[(NSObject *)delegate
				 performSelectorOnMainThread:@selector(adFlakeConfigDidReceiveConfig:)
				 withObject:config
				 waitUntilDone:NO];
			}
			return config;
		}
		// If there's already a config fetching, and another call to this function
		// add a delegate to the config
		[config addDelegate:delegate];
		return config;
	}

	// No config, create one, and start fetching it
	return [self fetchConfig:appKey delegate:delegate];
}

- (AdFlakeConfig *)fetchConfig:(NSString *)appKey
                      delegate:(id <AdFlakeConfigDelegate>)delegate {

	AdFlakeConfig *config = [[AdFlakeConfig alloc] initWithAppKey:appKey
														 delegate:delegate];

	if (fetchingConfig_ != nil) {
		AFLogWarn(@"Another fetch is in progress, wait until finished.");
		[config release];
		return nil;
	}
	fetchingConfig_ = config;

	if (![self checkReachability]) {
		[config release];
		return nil;
	}

	[configs_ setObject:config forKey:appKey];
	[config release];
	return config;
}

- (void)dealloc {
	if (reachability_ != nil) {
		reachability_.delegate = nil;
		[reachability_ release];
	}
	[connection_ release];
	[receivedData_ release];
	[configs_ release];
	[super dealloc];
}


#pragma mark private helper methods

// Check reachability first
- (BOOL)checkReachability {
	AFLogDebug(@"Checking if config is reachable at %@",
			   fetchingConfig_.configURL);

	// Normally reachability_ should be nil so a new one will be created.
	// In a testing environment, it may already have been assigned with a mock.
	// In any case, reachability_ will be released when the config URL is
	// reachable, in -reachabilityBecameReachable.
	if (reachability_ == nil) {
		reachability_ = [AFNetworkReachabilityWrapper
						 reachabilityWithHostname:[fetchingConfig_.configURL host]
						 callbackDelegate:self];
		[reachability_ retain];
	}
	if (reachability_ == nil) {
		[fetchingConfig_ notifyDelegatesOfFailure:
		 [AdFlakeError errorWithCode:AdFlakeConfigConnectionError
						 description:
		  @"Error setting up reachability check to config server"]];
		return NO;
	}

	if (![reachability_ scheduleInCurrentRunLoop]) {
		[fetchingConfig_ notifyDelegatesOfFailure:
		 [AdFlakeError errorWithCode:AdFlakeConfigConnectionError
						 description:
		  @"Error scheduling reachability check to config server"]];
		[reachability_ release], reachability_ = nil;
		return NO;
	}

	return YES;
}

// Make connection
- (void)startFetchingAssumingReachable {
	// go fetch config
	NSURLRequest *configRequest
    = [NSURLRequest requestWithURL:fetchingConfig_.configURL];

	// Normally connection_ should be nil so a new one will be created.
	// In a testing environment, it may alreay have been assigned with a mock.
	// In any case, connection_ will be release when connection failed or
	// finished.
	if (connection_ == nil) {
		connection_ = [[NSURLConnection alloc] initWithRequest:configRequest
													  delegate:self];
	}

	// Error checking
	if (connection_ == nil) {
		[self failedFetchingWithError:
		 [AdFlakeError errorWithCode:AdFlakeConfigConnectionError
						 description:
		  @"Error creating connection to config server"]];
		return;
	}
	receivedData_ = [[NSMutableData alloc] init];
}

// Clean up after fetching failed
- (void)failedFetchingWithError:(AdFlakeError *)error {
	// notify
	[fetchingConfig_ notifyDelegatesOfFailure:error];

	// remove the failed config from the cache
	[configs_ removeObjectForKey:fetchingConfig_.appKey];
	// the config is only retained by the dict,now released

	[self finishedFetching];
}

// Clean up after fetching, success or failed
- (void)finishedFetching {
	[connection_ release], connection_ = nil;
	[receivedData_ release], receivedData_ = nil;
	fetchingConfig_ = nil;
}


#pragma mark reachability methods

- (void)reachabilityNotReachable:(AFNetworkReachabilityWrapper *)reach {
	if (reach != reachability_) {
		AFLogWarn(@"Unrecognized reachability object called not reachable %s:%d",
				  __FILE__, __LINE__);
		return;
	}
	AFLogDebug(@"Config host %@ not (yet) reachable, check back later",
			   reach.hostname);
	[reachability_ release], reachability_ = nil;
	[self performSelector:@selector(checkReachability)
			   withObject:nil
			   afterDelay:10.0];
}

- (void)reachabilityBecameReachable:(AFNetworkReachabilityWrapper *)reach {
	if (reach != reachability_) {
		AFLogWarn(@"Unrecognized reachability object called reachable %s:%d",
				  __FILE__, __LINE__);
		return;
	}
	// done with the reachability
	[reachability_ release], reachability_ = nil;

	[self startFetchingAssumingReachable];
}


#pragma mark NSURLConnection delegate methods.

- (void)connection:(NSURLConnection *)conn
didReceiveResponse:(NSURLResponse *)response {
	if (conn != connection_) {
		AFLogError(@"Unrecognized connection object %s:%d", __FILE__, __LINE__);
		return;
	}
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse *http = (NSHTTPURLResponse*)response;
		const int status = [http statusCode];

		if (status < 200 || status >= 300) {
			AFLogWarn(@"AdFlakeConfig: HTTP %d, cancelling %@", status, [http URL]);
			[connection_ cancel];
			[self failedFetchingWithError:
			 [AdFlakeError errorWithCode:AdFlakeConfigStatusError
							 description:@"Config server did not return status 200"]];
			return;
		}
	}

	[receivedData_ setLength:0];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	if (conn != connection_) {
		AFLogError(@"Unrecognized connection object %s:%d", __FILE__, __LINE__);
		return;
	}
	[self failedFetchingWithError:
	 [AdFlakeError errorWithCode:AdFlakeConfigConnectionError
					 description:@"Error connecting to config server"
				 underlyingError:error]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	if (conn != connection_) {
		AFLogError(@"Unrecognized connection object %s:%d", __FILE__, __LINE__);
		return;
	}
	[fetchingConfig_ parseConfig:receivedData_ error:nil];
	[self finishedFetching];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	if (conn != connection_) {
		AFLogError(@"Unrecognized connection object %s:%d", __FILE__, __LINE__);
		return;
	}
	[receivedData_ appendData:data];
}

@end
