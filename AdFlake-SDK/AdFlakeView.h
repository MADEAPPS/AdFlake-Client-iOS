/**
 * AdFlakeView.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeView.h
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

#import <UIKit/UIKit.h>
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeConfig.h"
#import "AFNetworkReachabilityWrapper.h"

extern const int kAdFlakeAppClientVersion;

extern const float kAdFlakeViewWidth;
extern const float kAdFlakeViewHeight;
extern const CGSize kAdFlakeViewDefaultSize;
extern const CGRect kAdFlakeViewDefaultFrame;

extern NSString* const kAdFlakeDefaultConfigURL;
extern NSString* const kAdFlakeDefaultImpMetricURL;
extern NSString* const kAdFlakeDefaultClickMetricURL;
extern NSString* const kAdFlakeDefaultCustomAdURL;

extern const float kAdFlakeMinimumTimeBetweenFreshAdRequests;
extern const float kAdFlakeAdRequestTimeout;


@class AdFlakeAdNetworkConfig;
@class AdFlakeAdNetworkAdapter;
@class AdFlakeConfigStore;
@class AFNetworkReachabilityWrapper;


@interface AdFlakeView : UIView <AdFlakeConfigDelegate, AFNetworkReachabilityDelegate>
{
	id<AdFlakeDelegate> delegate;
	AdFlakeConfig *config;

	NSMutableArray *prioritizedAdNetCfgs;
	double totalPercent;

	BOOL ignoreAutoRefreshTimer;
	BOOL ignoreNewAdRequests;
	BOOL appInactive;
	BOOL showingModalView;

	BOOL requesting;
	AdFlakeAdNetworkAdapter *currAdapter;
	AdFlakeAdNetworkAdapter *lastAdapter;
	NSDate *lastRequestTime;
	NSMutableDictionary *pendingAdapters;

	NSTimer *refreshTimer;

	// remember which adapter we last sent click stats for so we don't send twice
	id lastNotifyAdapter;

	NSError *lastError;

	AdFlakeConfigStore *configStore;

	AFNetworkReachabilityWrapper *rollOverReachability;

	NSUInteger configFetchAttempts;

	NSArray *testDarts;
	NSUInteger testDartIndex;
}

/**
 * Call this method to get a view object that you can add to your own view. You
 * must also provide a delegate.  The delegate provides AdFlake's application
 * key and can listen for important messages.  You can configure the view's
 * settings and specific ad network information on AdFlake.com or your own
 * AdFlake server instance.
 */
+ (AdFlakeView *)requestAdFlakeViewWithDelegate:(id<AdFlakeDelegate>)delegate;

/**
 * Starts pre-fetching ad network configurations from an AdFlake server. If the
 * configuration has been fetched when you are ready to request an ad, you save
 * a round-trip to the network and hence your ad may show up faster. You
 * typically call this in the applicationDidFinishLaunching: method of your
 * app delegate. The request is non-blocking. You only need to call this
 * at most once per run of your application. Subsequent calls to this function
 * will be ignored.
 */
+ (void)startPreFetchingConfigurationDataWithDelegate:(id<AdFlakeDelegate>)d;

/**
 * Call this method to request a new configuration from the AdFlake servers.
 * This can be useful to support iOS 4.0 backgrounding.
 */
+ (void)updateAdFlakeConfigWithDelegate:(id<AdFlakeDelegate>)delegate;

/**
 * Call this method to request a new configuration from the AdFlake servers.
 */
- (void)updateAdFlakeConfig;

/**
 * Call this method to get another ad to display. You can also specify under
 * "app settings" on adflake.com to automatically get new ads periodically.
 */
- (void)requestFreshAd;

/**
 * Call this method if you prefer a rollover instead of a getNextAd call.  This
 * is offered primarily for developers who want to use generic notifications and
 * then execute a rollover when an ad network fails to serve an ad.
 */
- (void)rollOver;

/**
 * The delegate is informed asynchronously whether an ad succeeds or fails to
 * load. If you prefer to poll for this information, you can do so using this
 * method.
 *
 */
- (BOOL)adExists;

/**
 * Different ad networks may return different ad sizes. You may adjust the size
 * of the AdFlakeView and your UI to avoid unsightly borders or chopping off
 * pixels from ads. Call this method when you receive the adFlakeDidReceiveAd
 * delegate method to get the size of the underlying ad network ad.
 */
- (CGSize)actualAdSize;

/**
 * Some ad networks may offer different banner sizes for different orientations.
 * Call this function when the orientation of your UI changes so the underlying
 * ad may handle the orientation change properly. You may also want to
 * call the actualAdSize method right after calling this to get the size of
 * the ad after the orientation change.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

/**
 * Call this method to get the name of the most recent ad network that an ad
 * request was made to.
 */
- (NSString *)mostRecentNetworkName;

/**
 * Call this method to ignore the automatic refresh timer.
 *
 * Note that the refresh timer is NOT invalidated when you call
 * ignoreAutoRefreshTimer.
 * This will simply ignore the refresh events that are called by the automatic
 * refresh timer (if the refresh timer is enabled via adflake.com).  So, for
 * example, let's say you have a refresh cycle of 60 seconds.  If you call
 * ignoreAutoRefreshTimer at 30 seconds, and call resumeRefreshTimer at 90 sec,
 * then the first refresh event is ignored, but the second refresh event at 120
 * sec will run.
 */
- (void)ignoreAutoRefreshTimer;
- (void)doNotIgnoreAutoRefreshTimer;
- (BOOL)isIgnoringAutoRefreshTimer;

/**
 * Call this method to ignore automatic refreshes AND manual refreshes entirely.
 *
 * This is provided for developers who asked to disable refreshing entirely,
 * whether automatic or manual.
 * If you call ignoreNewAdRequests, the AdFlake will:
 * 1) Ignore any Automatic refresh events (via the refresh timer) AND
 * 2) Ignore any manual refresh calls (via requestFreshAd and rollOver)
 */
- (void)ignoreNewAdRequests;
- (void)doNotIgnoreNewAdRequests;
- (BOOL)isIgnoringNewAdRequests;

/**
 * Call this to replace the content of this AdFlakeView with the view.
 */
- (void)replaceBannerViewWith:(UIView*)bannerView;

/**
 * You can set the delegate to nil or another object.
 * Make sure you set the delegate to nil when you release an AdFlakeView
 * instance to avoid the AdFlakeView from calling to a non-existent delegate.
 * If you set the delegate to another object, note that if the new delegate
 * returns a different value for adFlakeApplicationKey, it will not overwrite
 * the application key provided by the delegate you supplied for
 * +requestAdFlakeViewWithDelegate .
 */
@property (nonatomic, assign) IBOutlet id<AdFlakeDelegate> delegate;

/**
 * Use this to retrieve more information after your delegate received a
 * adFlakeDidFailToReceiveAd message.
 */
@property (nonatomic, readonly) NSError *lastError;


#pragma mark - Interal: ad network adapters use only

/**
 * Called by Adapters when there's a new ad view.
 */
- (void)adapter:(AdFlakeAdNetworkAdapter *)adapter didReceiveAdView:(UIView *)view;

/**
 * Called by Adapters when ad view failed.
 */
- (void)adapter:(AdFlakeAdNetworkAdapter *)adapter didFailAd:(NSError *)error;

/**
 * Called by Adapters when the ad request is finished, but the ad view is
 * furnished elsewhere. e.g. Generic Notification
 */
- (void)adapterDidFinishAdRequest:(AdFlakeAdNetworkAdapter *)adapter;

@end
