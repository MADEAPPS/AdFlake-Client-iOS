/**
 * AdFlakeAdNetworkAdapter.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdNetworkAdapter.h
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

#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeConfig.h"

typedef enum {
	AdFlakeAdNetworkTypeAdMob             = 1,
	AdFlakeAdNetworkTypeJumpTap           = 2,
	AdFlakeAdNetworkTypeVideoEgg          = 3,
	AdFlakeAdNetworkTypeMedialets         = 4,	/**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeLiveRail          = 5,	/**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeMillennial        = 6,
	AdFlakeAdNetworkTypeGreyStripe        = 7,
	AdFlakeAdNetworkTypeQuattro           = 8,	 /**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeCustom            = 9,
	AdFlakeAdNetworkTypeAdFlake10         = 10,
	AdFlakeAdNetworkTypeMobClix           = 11,
	AdFlakeAdNetworkTypeMdotM             = 12,
	AdFlakeAdNetworkTypeAdFlake13         = 13,
	AdFlakeAdNetworkTypeGoogleAdSense     = 14, /**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeGoogleDoubleClick = 15, /**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeGeneric           = 16,
	AdFlakeAdNetworkTypeEvent             = 17,
	AdFlakeAdNetworkTypeInMobi            = 18,
	AdFlakeAdNetworkTypeIAd               = 19,
	AdFlakeAdNetworkTypeKomliMobile		  = 20,
	AdFlakeAdNetworkTypeBrightRoll        = 21,
	AdFlakeAdNetworkTypeTapAd             = 22,	/**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeOneRiot           = 23,	/**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeNexage            = 24, /**< NOTE: this network is defunct. */
	AdFlakeAdNetworkTypeAmazonAds		  = 25,
	AdFlakeAdNetworkTypeLeadBolt		  = 26,
	AdFlakeAdNetworkTypeMobFox			  = 27,
	AdFlakeAdNetworkTypeMojiva			  = 28,
	AdFlakeAdNetworkTypeHuntMobile		  = 29,
	AdFlakeAdNetworkTypeTodacell		  = 30
} AdFlakeAdNetworkType;

@class AdFlakeView;
@class AdFlakeConfig;
@class AdFlakeAdNetworkConfig;

@interface AdFlakeAdNetworkAdapter : NSObject {
	id<AdFlakeDelegate> adFlakeDelegate;
	AdFlakeView *adFlakeView;
	AdFlakeConfig *adFlakeConfig;
	AdFlakeAdNetworkConfig *networkConfig;
	UIView *adNetworkView;
}

/**
 * Subclasses must implement +networkType to return an AdFlakeAdNetworkType enum.
 */
//+ (AdFlakeAdNetworkType)networkType;

/**
 * Subclasses must add itself to the AdFlakeAdNetworkRegistry. One way
 * to do so is to implement the +load function and register there.
 */
//+ (void)load;

/**
 * Default initializer. Subclasses do not need to override this method unless
 * they need to perform additional initialization. In which case, this
 * method must be called via the super keyword.
 */
- (id)initWithAdFlakeDelegate:(id<AdFlakeDelegate>)delegate
                         view:(AdFlakeView *)view
                       config:(AdFlakeConfig *)config
                networkConfig:(AdFlakeAdNetworkConfig *)netConf;

/**
 * Ask the adapter to get an ad. This must be implemented by subclasses.
 */
- (void)getAd;

/**
 * When called, the adapter must remove itself as a delegate or notification
 * observer from the underlying ad network SDK. Subclasses must implement this
 * method, even if the underlying SDK doesn't have a way of removing delegate
 * (in which case, you should contact the ad network). Note that this method
 * will be called in dealloc at AdFlakeAdNetworkAdapter, before adNetworkView
 * is released. Care must be taken if you also keep a reference of your ad view
 * in a separate instance variable, as you may have released that variable
 * before this gets called in AdFlakeAdNetworkAdapter's dealloc. Use
 * adNetworkView, defined in this class, instead of your own instance variable.
 * This function should also be idempotent, i.e. get called multiple times and
 * not crash.
 */
- (void)stopBeingDelegate;

/**
 * Subclasses return YES to ask AdFlakeView to send metric requests to the
 * AdFlake server for ad impressions. Default is YES.
 */
- (BOOL)shouldSendExMetric;

/**
 * Tell the adapter that the interface orientation changed or is about to change
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

/**
 * Some ad transition types may cause issues with particular ad networks. The
 * adapter should know whether the given animation type is OK. Defaults to
 * YES.
 */
- (BOOL)isBannerAnimationOK:(AFBannerAnimationType)animType;

@property (nonatomic,assign) id<AdFlakeDelegate> adFlakeDelegate;
@property (nonatomic,assign) AdFlakeView *adFlakeView;
@property (nonatomic,retain) AdFlakeConfig *adFlakeConfig;
@property (nonatomic,retain) AdFlakeAdNetworkConfig *networkConfig;
@property (nonatomic,retain) UIView *adNetworkView;

@end


/**
 * Additional Helper Methods
 */
@interface AdFlakeAdNetworkAdapter (Helpers)

/**
 * Subclasses call this to notify delegate that there's going to be a full
 * screen modal (usually after tap).
 */
- (void)helperNotifyDelegateOfFullScreenModal;

/**
 * Subclasses call this to notify delegate that the full screen modal has
 * been dismissed.
 */
- (void)helperNotifyDelegateOfFullScreenModalDismissal;

/**
 * Subclasses call to get various configs to use, from the AdFlakeDelegate or
 * config from server.
 */
- (UIColor *)helperBackgroundColorToUse;
- (UIColor *)helperTextColorToUse;
- (UIColor *)helperSecondaryTextColorToUse;
- (NSInteger)helperCalculateAge;
- (bool) helperUseTestAds;

/**
 * Subclasses call to message the AdFlakeDelegate with various selectors.
 */
- (NSObject *)helperDelegateValueForSelector:(SEL)selector;

@end

