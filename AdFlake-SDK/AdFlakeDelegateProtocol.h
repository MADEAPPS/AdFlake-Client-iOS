/**
 * AdFlakeDelegateProtocol.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeDelegateProtocol.h
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

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class AdFlakeView;

@protocol AdFlakeDelegate<NSObject>

@required

/**
 * Return the AdFlake Application SDK key here. The SDK key is visible in the detail page of an app
 * in our backend.
 */
- (NSString *)adFlakeApplicationKey;

/**
 * The view controller with which the ad network will display a modal view
 * (web view, canvas), such as when the user clicks on the ad. You must
 * supply a view controller. You should return the root view controller
 * of your application, such as the root UINavigationController, or
 * any controllers that are pushed/added directly to the root view controller.
 * For example, if your app delegate has a pointer to the root view controller:
 *
 * return [(MyAppDelegate *)[[UIApplication sharedApplication] delegate] rootViewController]
 *
 * will suffice.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional

#pragma mark - Server endpoints
/**
 * If you are running your own AdFlake server instance, make sure you
 * implement the following to return the URL that points to the endpoints
 * on your server.
 */
- (NSURL *)adFlakeConfigURL;
- (NSURL *)adFlakeImpMetricURL;
- (NSURL *)adFlakeClickMetricURL;
- (NSURL *)adFlakeCustomAdURL;


#pragma mark - Notifications
/**
 * You can listen to callbacks from AdFlake via these methods.  When AdFlake is
 * notified that an ad request is fulfilled, it will notify you immediately.
 * Thus, when notified that an ad request succeeded, you can choose to add the
 * AdFlakeView object as a subview to your view.  This view contains the ad.
 * When you are notified that an ad request failed, you are also informed if the
 * AdFlakeView is fetching a backup ad.  The backup fetching order is specified
 * by you in adflake.com or your own server instance.  When all backup sources
 * are attempted and the last ad request still fails, the usingBackup parameter
 * will be set to NO.  You can use this notification to try again and perhaps
 * request another AdFlakeView via [AdFlakeView requestAdFlakeViewWithDelegate:]
 */
- (void)adFlakeDidReceiveAd:(AdFlakeView *)adFlakeView;
- (void)adFlakeDidFailToReceiveAd:(AdFlakeView *)adFlakeView usingBackup:(BOOL)yesOrNo;

/**
 * You can get notified when the transition animation to a new ad is completed
 * so you can make necessary adjustments to the size of the adFlakeView and
 * surrounding views after the animation.
 */
- (void)adFlakeDidAnimateToNewAdIn:(AdFlakeView *)adFlakeView;

/**
 * This function is your integration point for Generic Notifications. You can
 * control when this notification occurs via the developers member section.  You
 * can allocate a percentage of your ad requests to initiate this callback.  When
 * you receive this notification, you can execute any code block that you own.
 * For example, you can replace the ad in AdFlakeView after getting this callback
 * by calling replaceBannerViewWith: . Note that the ad refresh cycle is still
 * alive, so your view could be replaced by other ads when it's time for an
 * ad refresh.
 */
- (void)adFlakeReceivedRequestForDeveloperToFufill:(AdFlakeView *)adFlakeView;

/**
 * In the event that ads are OFF, you can listen to this callback method to
 * determine that ads have been turned off.
 */
- (void)adFlakeReceivedNotificationAdsAreOff:(AdFlakeView *)adFlakeView;

/**
 * These notifications will let you know when a user is being shown a full screen
 * webview canvas with an ad because they tapped on an ad.  You should listen to
 * these notifications to determine when to pause/resume your game--if you're
 * building a game app.
 */
- (void)adFlakeWillPresentFullScreenModal;
- (void)adFlakeDidDismissFullScreenModal;

/**
 * An ad request is a two step process: first the SDK must go to the AdFlake
 * server to retrieve configuration information. Then, based on the configuration
 * information, it chooses an ad network and fetch an ad. The following call
 * is for users to get notified when the first step is complete. The
 * adFlakeView passed could be null if you had called the AdFlakeView class
 * method +startPreFetchingConfigurationDataWithDelegate .
 */
- (void)adFlakeDidReceiveConfig:(AdFlakeView *)adFlakeView;


#pragma mark - Behavior configurations

/**
 * Request test ads for APIs that supports it. Make sure you turn it to OFF
 * or remove the function before you submit your app to the app store.
 */
- (BOOL)adFlakeTestMode;

/**
 * Returns the device's current orientation for ad networks that relys on
 * it. If you don't implement this function, [UIDevice currentDevice].orientation
 * is used to get the current orientation.
 */
- (UIDeviceOrientation)adFlakeCurrentOrientation;

#pragma mark - Appearance configurations
- (UIColor *)adFlakeAdBackgroundColor;
- (UIColor *)adFlakeTextColor;
- (UIColor *)adFlakeSecondaryTextColor;


#pragma mark - Hard-coded application keys
- (NSString *)admobPublisherID; // your Publisher ID from Admob.
- (NSString *)millennialMediaApIDString;  // your ApID string from Millennial Media.
- (NSString *)MdotMApplicationKey; // your Application Code from MdotM
- (NSString *)komliMobileClientID; // your clientID from Komli Mobile
- (NSString *)brightRollAppId; // your BrightRoll App ID
- (NSString *)inMobiAppID; // your inMobi app ID
- (NSString *)mobClixAppIDString;
- (NSDictionary *)nexageDictionary; // your nexage dcn and position
- (NSDictionary *)sayMediaConfigDictionary;  // key-value pairs for the keys "publisher" and "area" information from Say Media.  Set NSString values for these two keys.


#pragma mark - Demographic information optional delegate methods
- (NSDate *)dateOfBirth; // user's date of birth
- (NSString *)postalCode; // user's postal code, e.g. "94401"
- (NSString *)areaCode; // user's area code, e.g. "415"
- (NSString *)gender; // user's gender (e.g. @"m" or @"f")
- (NSString *)keywords; // keywords the user has provided or that are contextually relevant, e.g. @"twitter client iPhone"
- (NSString *)searchString; // a search string the user has provided, e.g. @"Jasmine Tea House San Francisco"
- (NSUInteger)incomeLevel; // return actual annual income
- (CLLocation *)locationInfo; // user's current location


#pragma mark - AD network specific optional delegate methods -

#pragma mark GreyStripe optional delegate methods

- (BOOL) greystripeShouldDisplayFullScreenAd;

#pragma mark MillennialMedia-specific optional delegate methods
/**
 * Return the ad type desired for Millennial Media, depending on your ad position
 * MMBannerAdTop = 1,
 * MMBannerAdBottom = 2,
 */
- (NSUInteger)millennialMediaAdType;

/**
 * Return a value for the education level if you have access to this info.  This
 * information will be relayed to Millennial Media if provided
 * MMEducationUnknown = 0,
 * MMEducationHishSchool = 1,
 * MMEducationSomeCollege = 2,
 * MMEducationInCollege = 3,
 * MMEducationBachelorsDegree = 4,
 * MMEducationMastersDegree = 5,
 * MMEducationPhD = 6
 */
- (NSUInteger)millennialMediaEducationLevel;

/**
 * Return a value for ethnicity if you have access to this info.  This
 * information will be relayed to Millennial Media if provided.
 * MMEthnicityUnknown = 0,
 * MMEthnicityAfricanAmerican = 1,
 * MMEthnicityAsian = 2,
 * MMEthnicityCaucasian = 3,
 * MMEthnicityHispanic = 4,
 * MMEthnicityNativeAmerican = 5,
 * MMEthnicityMixed = 6
 */
- (NSUInteger)millennialMediaEthnicity;


#pragma mark Jumptap-specific optional delegate methods
/**
 * optional site and spot id as provided by Jumptap.
 */
- (NSString *)jumptapSiteId;
- (NSString *)jumptapSpotId;

/**
 * Find a list of valid categories at https://support.jumptap.com/index.php/Valid_Categories
 */
- (NSString *)jumptapCategory;

/**
 * Whether adult content is allowed.
 * AdultContentAllowed = 0,
 * AdultContentNotAllowed = 1,
 * AdultContentOnly = 2
 */
- (NSUInteger)jumptapAdultContent;

/**
 * The transition to use when moving from, say, a banner to full-screen.
 * TransitionHorizontalSlide = 0,
 * TransitionVerticalSlide = 1,
 * TransitionCurl = 2,
 * TransitionFlip = 3
 */
- (NSUInteger)jumptapTransitionType;

#pragma mark InMobi-specific optional delegate methods
/**
 * Education level for InMobi
 * Edu_None = 0
 * Edu_HighSchool = 1
 * Edu_SomeCollege = 2
 * Edu_InCollege = 3
 * Edu_BachelorsDegree = 4
 * Edu_MastersDegree = 5
 * Edu_DoctoralDegree = 6
 * Edu_Other = 7
 */
- (NSUInteger)inMobiEducation;

/**
 Eth_None = 0,
 Eth_Mixed = 1,
 Eth_Asian = 2,
 Eth_Black = 3,
 Eth_Hispanic = 4,
 Eth_NativeAmerican = 5,
 Eth_White = 6,
 Eth_Other = 7
 */
- (NSUInteger)inMobiEthnicity;

/**
 * See inMobi's documentation for valid values
 */
- (NSString *)inMobiInterests;

- (NSString *)iAdAdvertisingSection;

- (NSDictionary *)inMobiParamsDictionary;

#pragma mark Nexage-specific optional delegate methods
-(NSString *)nexageCity;
-(NSString *)nexageDesignatedMarketArea;
-(NSString *)nexageCountry;
-(NSString *)nexageEthnicity;
-(NSString *)nexageMaritalStatus;

@end
