/**
 * AdNetwork.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdNetwork.m
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

#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkRegistry.h"
#import "AdFlakeCommon.h"

#define kAdFlakePubIdKey @"pubid"

@implementation AdFlakeAdNetworkConfig

@synthesize networkType;
@synthesize nid;
@synthesize networkName;
@synthesize trafficPercentage;
@synthesize priority;
@synthesize credentials;
@synthesize adapterClass;

- (id)initWithDictionary:(NSDictionary *)adNetConfigDict
       adNetworkRegistry:(AdFlakeAdNetworkRegistry *)registry
                   error:(AdFlakeError **)error {
	self = [super init];

	if (self != nil) {
		NSInteger temp;
		id ntype = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyType];
		id netId = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyNID];
		id netName = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyName];
		id weight = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyWeight];
		id pri = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyPriority];

		if (ntype == nil || netId == nil || netName == nil || pri == nil) {
			NSString *errorMsg =
			@"Ad network config has no network type, network id, network name, or priority";
			if (error != nil) {
				*error = [AdFlakeError errorWithCode:AdFlakeConfigDataError
										 description:errorMsg];
			}
			else {
				AFLogWarn(errorMsg);
			}

			[self release];
			return nil;
		}

		if (AFGetIntegerValue(&temp, ntype)) {
			networkType = temp;
		}
		if ([netId isKindOfClass:[NSString class]]) {
			nid = [[NSString alloc] initWithString:netId];
		}
		if ([netName isKindOfClass:[NSString class]]) {
			networkName = [[NSString alloc] initWithString:netName];
		}

		double tempDouble;
		if (weight == nil) {
			trafficPercentage = 0.0;
		}
		else if (AFGetDoubleValue(&tempDouble, weight)) {
			trafficPercentage = tempDouble;
		}

		if (AFGetIntegerValue(&temp, pri)) {
			priority = temp;
		}

		if (networkType == 0 || nid == nil || networkName == nil || priority == 0) {
			NSString *errorMsg =
			@"Ad network config has invalid network type, network id, network name or priority";
			if (error != nil) {
				*error = [AdFlakeError errorWithCode:AdFlakeConfigDataError
										 description:errorMsg];
			}
			else {
				AFLogWarn(errorMsg);
			}

			[self release];
			return nil;
		}

		id cred = [adNetConfigDict objectForKey:AFAdNetworkConfigKeyCred];
		if (cred == nil) {
			credentials = nil;
		}
		else {
			if ([cred isKindOfClass:[NSDictionary class]]) {
				credentials = [[NSDictionary alloc] initWithDictionary:cred copyItems:YES];
			}
			else if ([cred isKindOfClass:[NSString class]]) {
				credentials = [[NSDictionary alloc] initWithObjectsAndKeys:
							   [NSString stringWithString:cred], kAdFlakePubIdKey,
							   nil];
			}
		}

		adapterClass = [registry adapterClassFor:networkType].theClass;
		if (adapterClass == nil) {
			NSString *errorMsg =
			[NSString stringWithFormat:@"Ad network type %d not supported, no adapter found",
			 networkType];
			if (error != nil) {
				*error = [AdFlakeError errorWithCode:AdFlakeConfigDataError
										 description:errorMsg];
			}
			else {
				AFLogWarn(errorMsg);
			}

			[self release];
			return nil;
		}
		
		if ([adapterClass respondsToSelector:@selector(prepareForConfig:)])
		{
			[adapterClass performSelector:@selector(prepareForConfig:) withObject:self];
		}
	}

	return self;
}

- (NSString *)pubId {
	if (credentials == nil) return nil;
	return [credentials objectForKey:kAdFlakePubIdKey];
}

- (NSString *)description {
	NSString *creds = [self pubId];
	if (creds == nil) {
		creds = @"{";
		for (NSString *k in [credentials keyEnumerator]) {
			creds = [creds stringByAppendingFormat:@"%@:%@ ",
					 k, [credentials objectForKey:k]];
		}
		creds = [creds stringByAppendingString:@"}"];
	}
	return [NSString stringWithFormat:
			@"name:%@ type:%d nid:%@ weight:%lf priority:%d creds:%@",
			networkName, networkType, nid, trafficPercentage, priority, creds];
}

- (void)dealloc {
	[nid release], nid = nil;
	[networkName release], networkName = nil;
	[credentials release], credentials = nil;
	
	[super dealloc];
}

@end


@implementation UIColor (AdFlakeConfig)

- (id)initWithDict:(NSDictionary *)dict {
	id red, green, blue, alpha;
	CGFloat r, g, b, a;

	red   = [dict objectForKey:@"red"];
	if (red == nil) {
		[self release];
		return nil;
	}
	green = [dict objectForKey:@"green"];
	if (green == nil) {
		[self release];
		return nil;
	}
	blue  = [dict objectForKey:@"blue"];
	if (blue == nil) {
		[self release];
		return nil;
	}

	NSInteger temp;
	if (!AFGetIntegerValue(&temp, red)) {
		[self release];
		return nil;
	}
	r = (CGFloat)temp/255.0;
	if (!AFGetIntegerValue(&temp, green)) {
		[self release];
		return nil;
	}
	g = (CGFloat)temp/255.0;
	if (!AFGetIntegerValue(&temp, blue)) {
		[self release];
		return nil;
	}
	b = (CGFloat)temp/255.0;

	a = 1.0; // default 1.0
	alpha = [dict objectForKey:@"alpha"];
	CGFloat temp_f;
	if (alpha != nil && AFGetFloatValue(&temp_f, alpha)) {
		a = (CGFloat)temp_f;
	}

	return [self initWithRed:r green:g blue:b alpha:a];
}

@end
