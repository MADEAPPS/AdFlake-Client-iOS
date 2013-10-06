/**
 * AdFlakeAdNetworkRegistry.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdNetworkRegistry.m
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

#import "AdFlakeAdNetworkRegistry.h"
#import "AdFlakeAdNetworkAdapter.h"

@protocol AdFlakeClassNetworkType<NSObject>

- (AdFlakeAdNetworkType) networkType;

@end

@implementation AdFlakeAdNetworkRegistry

+ (AdFlakeAdNetworkRegistry *)sharedRegistry {
	static AdFlakeAdNetworkRegistry *registry = nil;
	if (registry == nil) {
		registry = [[AdFlakeAdNetworkRegistry alloc] init];
	}
	return registry;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		adapterDict = [[NSMutableDictionary alloc] init];
	}
	return self;  
}

- (void)registerClass:(Class)adapterClass {
	// have to do all these to avoid compiler warnings...
	NSInteger (*netTypeMethod)(id, SEL);
	netTypeMethod = (NSInteger (*)(id, SEL))[adapterClass methodForSelector:@selector(networkType)];
	NSInteger netType = netTypeMethod(adapterClass, @selector(networkType));
	NSNumber *key = [[NSNumber alloc] initWithInteger:netType];
	AdFlakeClassWrapper *wrapper = [[AdFlakeClassWrapper alloc] initWithClass:adapterClass];
	[adapterDict setObject:wrapper forKey:key];
	[key release];
	[wrapper release];
}

- (AdFlakeClassWrapper *)adapterClassFor:(NSInteger)adNetworkType {
	return [adapterDict objectForKey:[NSNumber numberWithInteger:adNetworkType]];
}

- (void)dealloc {
	[adapterDict release], adapterDict = nil;
	[super dealloc];
}

@end


@implementation AdFlakeClassWrapper

@synthesize theClass;

- (id)initWithClass:(Class)c {
	self = [super init];
	if (self != nil) {
		theClass = c;
	}
	return self;
}

@end

