/**
 * AdFlakeConfig.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeConfig.h
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
#import <UIKit/UIKit.h>
#import "CJSONDeserializer.h"

@class AdFlakeConfig;
@protocol AdFlakeConfigDelegate<NSObject>

@optional
- (void)adFlakeConfigDidReceiveConfig:(AdFlakeConfig *)config;
- (void)adFlakeConfigDidFail:(AdFlakeConfig *)config error:(NSError *)error;
- (NSURL *)adFlakeConfigURL;

@end

typedef enum {
	AFBannerAnimationTypeNone           = 0,
	AFBannerAnimationTypeFlipFromLeft   = 1,
	AFBannerAnimationTypeFlipFromRight  = 2,
	AFBannerAnimationTypeCurlUp         = 3,
	AFBannerAnimationTypeCurlDown       = 4,
	AFBannerAnimationTypeSlideFromLeft  = 5,
	AFBannerAnimationTypeSlideFromRight = 6,
	AFBannerAnimationTypeFadeIn         = 7,
	AFBannerAnimationTypeRandom         = 8,
} AFBannerAnimationType;

@class AdFlakeAdNetworkConfig;
@class AdFlakeAdNetworkRegistry;

@interface AdFlakeConfig : NSObject {
	NSString *appKey;
	NSURL *configURL;
	BOOL legacy;

	BOOL adsAreOff, videoAdsAreOff;
	NSMutableArray *adNetworkConfigs;
	NSMutableArray *videoAdNetworkConfigs;

	UIColor *backgroundColor;
	UIColor *textColor;
	NSTimeInterval refreshInterval;
	BOOL locationOn;
	AFBannerAnimationType bannerAnimationType;
	NSInteger fullscreenWaitInterval;
	NSInteger fullscreenMaxAds;

	NSMutableArray *delegates;
	BOOL hasConfig;

	AdFlakeAdNetworkRegistry *adNetworkRegistry;
}

- (id)initWithAppKey:(NSString *)ak delegate:(id<AdFlakeConfigDelegate>)delegate;
- (BOOL)parseConfig:(NSData *)data error:(NSError **)error;
- (BOOL)addDelegate:(id<AdFlakeConfigDelegate>)delegate;
- (BOOL)removeDelegate:(id<AdFlakeConfigDelegate>)delegate;
- (void)notifyDelegatesOfFailure:(NSError *)error;

@property (nonatomic,readonly) NSString *appKey;
@property (nonatomic,readonly) NSURL *configURL;

@property (nonatomic,readonly) BOOL hasConfig;

@property (nonatomic,readonly) BOOL adsAreOff, videoAdsAreOff;
@property (nonatomic,readonly) NSArray *adNetworkConfigs, *videoAdNetworkConfigs;
@property (nonatomic,readonly) UIColor *backgroundColor;
@property (nonatomic,readonly) UIColor *textColor;
@property (nonatomic,readonly) NSTimeInterval refreshInterval;
@property (nonatomic,readonly) BOOL locationOn;
@property (nonatomic,readonly) AFBannerAnimationType bannerAnimationType;
@property (nonatomic,readonly) NSInteger fullscreenWaitInterval;
@property (nonatomic,readonly) NSInteger fullscreenMaxAds;

@property (nonatomic,assign) AdFlakeAdNetworkRegistry *adNetworkRegistry;

@end


// Convenience conversion functions, converts val into native types var.
// val can be NSNumber or NSString, all else will cause function to fail
// On failure, return NO.
BOOL AFGetIntegerValue(NSInteger *var, id val);
BOOL AFGetFloatValue(CGFloat *var, id val);
BOOL AFGetDoubleValue(double *var, id val);
