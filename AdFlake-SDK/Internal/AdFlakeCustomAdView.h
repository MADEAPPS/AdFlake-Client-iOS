/**
 * AdFlakeCustomAdView.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeCustomAdView.h
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

typedef enum {
	AFCustomAdTypeMIN = 0,
	AFCustomAdTypeBanner    = 1,
	AFCustomAdTypeText      = 2,
	AFCustomAdTypeAutoLaunchFallBackBanner = 3,
	AFCustomAdTypeAutoLaunchFallBackText   = 4,
	AFCustomAdTypeSearchBar = 5,
	AFCustomAdTypeMAX = 6
} AFCustomAdType;

typedef enum {
	AFCustomAdLaunchTypeMIN = 0,
	AFCustomAdLaunchTypeSafari   = 1,
	AFCustomAdLaunchTypeCanvas   = 2,
	AFCustomAdLaunchTypeSafariRedirectFollowThrough = 3,
	AFCustomAdLaunchTypeMAX = 4
} AFCustomAdLaunchType;

typedef enum {
	AFCustomAdWebViewAnimTypeMIN = -1,
	AFCustomAdWebViewAnimTypeNone           = 0,
	AFCustomAdWebViewAnimTypeFlipFromLeft   = 1,
	AFCustomAdWebViewAnimTypeFlipFromRight  = 2,
	AFCustomAdWebViewAnimTypeCurlUp         = 3,
	AFCustomAdWebViewAnimTypeCurlDown       = 4,
	AFCustomAdWebViewAnimTypeSlideFromLeft  = 5,
	AFCustomAdWebViewAnimTypeSlideFromRight = 6,
	AFCustomAdWebViewAnimTypeFadeIn         = 7,
	AFCustomAdWebViewAnimTypeModal          = 8,
	AFCustomAdWebViewAnimTypeRandom         = 9,
	AFCustomAdWebViewAnimTypeMAX = 10
} AFCustomAdWebViewAnimType;

@class AdFlakeCustomAdView;

@protocol AdFlakeCustomAdViewDelegate<NSObject>

- (void)adTapped:(AdFlakeCustomAdView *)adView;

@end


@interface AdFlakeCustomAdView : UIButton
{
	id<AdFlakeCustomAdViewDelegate> delegate;
	UIImage *image;
	UILabel *textLabel;
	NSURL *redirectURL;
	NSURL *clickMetricsURL;
	AFCustomAdType adType;
	AFCustomAdLaunchType launchType;
	AFCustomAdWebViewAnimType animType;
	UIColor *backgroundColor;
	UIColor *textColor;
}

- (id)initWithDelegate:(id<AdFlakeCustomAdViewDelegate>)delegate
                  text:(NSString *)text
           redirectURL:(NSURL *)redirectURL
       clickMetricsURL:(NSURL *)clickMetricsURL
                adType:(AFCustomAdType)adType
            launchType:(AFCustomAdLaunchType)launchType
              animType:(AFCustomAdWebViewAnimType)animType
       backgroundColor:(UIColor *)bgColor
             textColor:(UIColor *)fgColor;

@property (nonatomic,assign) id<AdFlakeCustomAdViewDelegate> delegate;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,readonly) UILabel *textLabel;
@property (nonatomic,readonly) NSURL *redirectURL;
@property (nonatomic,readonly) NSURL *clickMetricsURL;
@property (nonatomic,readonly) AFCustomAdType adType;
@property (nonatomic,readonly) AFCustomAdLaunchType launchType;
@property (nonatomic,readonly) AFCustomAdWebViewAnimType animType;
@property (nonatomic,readonly) UIColor *backgroundColor;
@property (nonatomic,readonly) UIColor *textColor;

@end
