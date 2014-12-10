/**
 * AdFlakeConfig.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeConfig.m
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

#import <CommonCrypto/CommonDigest.h>

#import "AdFlakeConfig.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeView.h"
#import "AdFlakeAdNetworkAdapter.h"
#import "AdFlakeAdNetworkRegistry.h"
#import "AFNetworkReachabilityWrapper.h"

// NOTE: we're disabling deprecated warning since we're also using the newer API
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

BOOL AFGetIntegerValue(NSInteger *var, id val) {
	if ([val isKindOfClass:[NSNumber class]] || [val isKindOfClass:[NSString class]]) {
		*var = [val integerValue];
		return YES;
	}
	return NO;
}

BOOL AFGetFloatValue(CGFloat *var, id val) {
	if ([val isKindOfClass:[NSNumber class]] || [val isKindOfClass:[NSString class]]) {
		*var = [val floatValue];
		return YES;
	}
	return NO;
}

BOOL AFGetDoubleValue(double *var, id val) {
	if ([val isKindOfClass:[NSNumber class]] || [val isKindOfClass:[NSString class]]) {
		*var = [val doubleValue];
		return YES;
	}
	return NO;
}


@implementation AdFlakeConfig

@synthesize appKey;
@synthesize configURL;
@synthesize adsAreOff, videoAdsAreOff;
@synthesize adNetworkConfigs, videoAdNetworkConfigs;
@synthesize backgroundColor;
@synthesize textColor;
@synthesize refreshInterval;
@synthesize locationOn;
@synthesize bannerAnimationType;
@synthesize fullscreenWaitInterval;
@synthesize fullscreenMaxAds;
@synthesize hasConfig;

@synthesize adNetworkRegistry;

#pragma mark -

- (id)initWithAppKey:(NSString *)ak delegate:(id<AdFlakeConfigDelegate>)delegate {
	self = [super init];
	if (self != nil) {
		appKey = [[NSString alloc] initWithString:ak];
		legacy = NO;
		adNetworkConfigs = [[NSMutableArray alloc] init];
		videoAdNetworkConfigs = [[NSMutableArray alloc] init];
		delegates = [[NSMutableArray alloc] init];
		hasConfig = NO;
		[self addDelegate:delegate];

		// object dependencies
		adNetworkRegistry = [AdFlakeAdNetworkRegistry sharedRegistry];

		// default values
		backgroundColor = [[UIColor alloc] initWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
		textColor = [[UIColor whiteColor] retain];
		refreshInterval = 60;
		locationOn = YES;
		bannerAnimationType = AFBannerAnimationTypeRandom;
		fullscreenWaitInterval = 60;
		fullscreenMaxAds = 2;

		// config URL
		NSURL *configBaseURL = nil;
		if ([delegate respondsToSelector:@selector(adFlakeConfigURL)]) {
			configBaseURL = [delegate adFlakeConfigURL];
		}
		if (configBaseURL == nil) {
			configBaseURL = [NSURL URLWithString:kAdFlakeDefaultConfigURL];
		}
		configURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"?appid=%@&appver=%d&client=1",
												   appKey,
												   kAdFlakeAppClientVersion]
									relativeToURL:configBaseURL];
	}
	return self;
}

- (BOOL)addDelegate:(id<AdFlakeConfigDelegate>)delegate {
	for (NSValue *w in delegates) {
		id<AdFlakeConfigDelegate> existing = [w nonretainedObjectValue];
		if (existing == delegate) {
			return NO; // already in the list of delegates
		}
	}
	NSValue *wrapped = [NSValue valueWithNonretainedObject:delegate];
	[delegates addObject:wrapped];
	return YES;
}

- (BOOL)removeDelegate:(id<AdFlakeConfigDelegate>)delegate {
	NSUInteger i;
	for (i = 0; i < [delegates count]; i++) {
		NSValue *w = [delegates objectAtIndex:i];
		id<AdFlakeConfigDelegate> existing = [w nonretainedObjectValue];
		if (existing == delegate) {
			break;
		}
	}
	if (i < [delegates count]) {
		[delegates removeObjectAtIndex:i];
		return YES;
	}
	return NO;
}

- (void)notifyDelegatesOfFailure:(NSError *)error {
	for (NSValue *wrapped in delegates) {
		id<AdFlakeConfigDelegate> delegate = [wrapped nonretainedObjectValue];
		if ([delegate respondsToSelector:@selector(adFlakeConfigDidFail:error:)]) {
			[delegate adFlakeConfigDidFail:self error:error];
		}
	}
}

- (NSString *)description {
	NSString *desc = [super description];
	NSString *configs = [NSString stringWithFormat:
						 @"location_access:%d fg_color:%@ bg_color:%@ cycle_time:%lf transition:%d",
						 locationOn, textColor, backgroundColor, refreshInterval, bannerAnimationType];
	return [NSString stringWithFormat:@"%@:\n%@ networks:%@\n video networks: %@", desc, configs, adNetworkConfigs, videoAdNetworkConfigs];
}

- (void)dealloc {
	[appKey release], appKey = nil;
	[configURL release], configURL = nil;
	[adNetworkConfigs release], adNetworkConfigs = nil;
	[videoAdNetworkConfigs release], videoAdNetworkConfigs = nil;
	[backgroundColor release], backgroundColor = nil;
	[textColor release], textColor = nil;
	[delegates release], delegates = nil;
	[super dealloc];
}

#pragma mark parsing methods

- (BOOL)parseExtraConfig:(NSDictionary *)configDict error:(NSError **)error {
	id bgColor = [configDict objectForKey:@"background_color_rgb"];
	if (bgColor != nil && [bgColor isKindOfClass:[NSDictionary class]]) {
		[backgroundColor release];
		backgroundColor = [[UIColor alloc] initWithDict:(NSDictionary *)bgColor];
	}
	id txtColor = [configDict objectForKey:@"text_color_rgb"];
	if (txtColor != nil && [txtColor isKindOfClass:[NSDictionary class]]) {
		[textColor release];
		textColor = [[UIColor alloc] initWithDict:txtColor];
	}
	id tempVal;
	tempVal = [configDict objectForKey:@"refresh_interval"];
	if (tempVal == nil)
		tempVal = [configDict objectForKey:@"cycle_time"];
	NSInteger tempInt;
	if (tempVal && AFGetIntegerValue(&tempInt, tempVal)) {
		refreshInterval = (NSTimeInterval)tempInt;
		if (refreshInterval >= 30000.0) {
			// effectively forever, set to 0
			refreshInterval = 0.0;
		}
	}
	if (AFGetIntegerValue(&tempInt, [configDict objectForKey:@"location_on"])) {
		locationOn = (tempInt == 0)? NO : YES;
		// check user preference. user preference of NO trumps all

		BOOL bLocationServiceEnabled = NO;
		if ([CLLocationManager respondsToSelector:
			 @selector(locationServicesEnabled)]) {
			bLocationServiceEnabled = [CLLocationManager locationServicesEnabled];
		}
		else {
			CLLocationManager* locMan = [[CLLocationManager alloc] init];

			if ([CLLocationManager respondsToSelector:@selector(locationServicesEnabled)])
				bLocationServiceEnabled = [CLLocationManager locationServicesEnabled];
			else
				bLocationServiceEnabled = locMan.locationServicesEnabled;
			[locMan release], locMan = nil;
		}

		if (locationOn == YES && bLocationServiceEnabled == NO) {
			AFLogDebug(@"User disabled location services, set locationOn to NO");
			locationOn = NO;
		}
	}
	tempVal = [configDict objectForKey:@"transition"];
	if (tempVal == nil)
		tempVal = [configDict objectForKey:@"banner_animation_type"];
	if (tempVal && AFGetIntegerValue(&tempInt, tempVal)) {
		switch (tempInt) {
			case 0: bannerAnimationType = AFBannerAnimationTypeNone; break;
			case 1: bannerAnimationType = AFBannerAnimationTypeFlipFromLeft; break;
			case 2: bannerAnimationType = AFBannerAnimationTypeFlipFromRight; break;
			case 3: bannerAnimationType = AFBannerAnimationTypeCurlUp; break;
			case 4: bannerAnimationType = AFBannerAnimationTypeCurlDown; break;
			case 5: bannerAnimationType = AFBannerAnimationTypeSlideFromLeft; break;
			case 6: bannerAnimationType = AFBannerAnimationTypeSlideFromRight; break;
			case 7: bannerAnimationType = AFBannerAnimationTypeFadeIn; break;
			case 8: bannerAnimationType = AFBannerAnimationTypeRandom; break;
		}
	}
	if (AFGetIntegerValue(&tempInt, [configDict objectForKey:@"fullscreen_wait_interval"])) {
		fullscreenWaitInterval = tempInt;
	}
	if (AFGetIntegerValue(&tempInt, [configDict objectForKey:@"fullscreen_max_ads"])) {
		fullscreenMaxAds = tempInt;
	}
	return YES;
}

- (BOOL)parseNewConfig:(NSDictionary *)configDict error:(NSError **)error {
	id extra = [configDict objectForKey:@"extra"];
	if (extra != nil && [extra isKindOfClass:[NSDictionary class]]) {
		NSDictionary *extraDict = extra;
		if (![self parseExtraConfig:extraDict error:error]) {
			return NO;
		}
	}
	else {
		AFLogWarn(@"No extra info dict in ad network config");
	}

	// parse ad rations
	{
		adsAreOff = YES;
		id rations = [configDict objectForKey:@"rations"];
		double totalWeight = 0.0;
		if (rations != nil && [rations isKindOfClass:[NSArray class]])
		{
			if ([(NSArray *)rations count] > 0)
			{
				adsAreOff = NO;
				for (id c in (NSArray *)rations) {
					if (![c isKindOfClass:[NSDictionary class]]) {
						AFLogWarn(@"Element in rations array is not a dictionary %@ in ad network config",c);
						continue;
					}
					AdFlakeError *adNetConfigError = nil;
					AdFlakeAdNetworkConfig *adNetConfig =
					[[AdFlakeAdNetworkConfig alloc] initWithDictionary:(NSDictionary *)c
													 adNetworkRegistry:adNetworkRegistry
																 error:&adNetConfigError];
					if (adNetConfig != nil) {
						[adNetworkConfigs addObject:adNetConfig];
						totalWeight += adNetConfig.trafficPercentage;
						[adNetConfig release];
					}
					else {
						AFLogWarn(@"Cannot create ad network config from %@: %@", c,
								  adNetConfigError != nil? [adNetConfigError localizedDescription]:@"");
					}
				}
			}
		}
		else {
			AFLogError(@"No rations array in ad network config");
		}
		
		if (totalWeight == 0.0) {
			adsAreOff = YES;
		}
	}
	// parse video ad rations
	{
		videoAdsAreOff = YES;
		id rations = [configDict objectForKey:@"videoRations"];
		double totalWeight = 0.0;
		
		if (rations != nil && [rations isKindOfClass:[NSArray class]])
		{
			if ([(NSArray *)rations count] > 0)
			{
				videoAdsAreOff = NO;
				for (id c in (NSArray *)rations) {
					if (![c isKindOfClass:[NSDictionary class]]) {
						AFLogWarn(@"Element in rations array is not a dictionary %@ in ad network config",c);
						continue;
					}
					AdFlakeError *adNetConfigError = nil;
					AdFlakeAdNetworkConfig *adNetConfig =
					[[AdFlakeAdNetworkConfig alloc] initWithDictionary:(NSDictionary *)c
													 adNetworkRegistry:adNetworkRegistry
																 error:&adNetConfigError];
					if (adNetConfig != nil) {
						[videoAdNetworkConfigs addObject:adNetConfig];
						totalWeight += adNetConfig.trafficPercentage;
						[adNetConfig release];
					}
					else {
						AFLogWarn(@"Cannot create video ad network config from %@: %@", c,
								  adNetConfigError != nil? [adNetConfigError localizedDescription]:@"");
					}
				}
			}
		}
		else {
			AFLogError(@"No video rations array in ad network config");
		}
		
		if (totalWeight == 0.0) {
			videoAdsAreOff = YES;
		}
	}

	return YES;
}

- (BOOL)parseConfig:(NSData *)data error:(NSError **)error {
	if (hasConfig) {
		if (error != NULL)
			*error = [AdFlakeError errorWithCode:AdFlakeConfigDataError
									 description:@"Already has config, will not parse"];
		return NO;
	}
	NSError *jsonError = nil;
	id parsed = [[CJSONDeserializer deserializer] deserialize:data error:&jsonError];
	if (parsed == nil) {
		if (error != NULL)
			*error = [AdFlakeError errorWithCode:AdFlakeConfigParseError
									 description:@"Error parsing config JSON from server"
								 underlyingError:jsonError];
		return NO;
	}
	if ([parsed isKindOfClass:[NSDictionary class]]) {
		// open-source AdFlake config
		if (![self parseNewConfig:(NSDictionary *)parsed error:error]) {
			return NO;
		}
	}
	else {
		if (error != NULL)
			*error = [AdFlakeError errorWithCode:AdFlakeConfigDataError
									 description:@"Expected top-level dictionary in config data"];
		return NO;
	}

	// parse success
	hasConfig = YES;

	// notify delegates of success
	for (NSValue *wrapped in delegates) {
		id<AdFlakeConfigDelegate> delegate = [wrapped nonretainedObjectValue];
		if ([delegate respondsToSelector:@selector(adFlakeConfigDidReceiveConfig:)]) {
			[delegate adFlakeConfigDidReceiveConfig:self];
		}
	}

	return YES;
}

@end
