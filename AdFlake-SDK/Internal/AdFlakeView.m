/**
 * AdFlakeView.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeView.m
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

#import "AdFlakeView.h"
#import "AdFlakeView+Internal.h"
#import "AdFlakeConfigStore.h"
#import "AdFlakeAdNetworkConfig.h"
#import "CJSONDeserializer.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkAdapter.h"
#import "AdFlakeConfigStore.h"
#import "AFNetworkReachabilityWrapper.h"

#define kAdFlakeViewAdSubViewTag   1000

const int kAdFlakeAppClientVersion = 400;

const float kAdFlakeViewWidth	= 320.0f;
const float kAdFlakeViewHeight	= 50.0f;
const CGSize kAdFlakeViewDefaultSize = { kAdFlakeViewWidth, kAdFlakeViewHeight };
const CGRect kAdFlakeViewDefaultFrame = { { 0.0f, 0.0f }, { kAdFlakeViewWidth, kAdFlakeViewHeight } };

NSString* const kAdFlakeDefaultConfigURL = @"http://api.adflake.com/get";
NSString* const kAdFlakeDefaultImpMetricURL = @"http://metrics.adflake.com/impression";
NSString* const kAdFlakeDefaultClickMetricURL = @"http://metrics.adflake.com/click";
NSString* const kAdFlakeDefaultCustomAdURL = @"http://api.adflake.com/custom";

const float kAdFlakeMinimumTimeBetweenFreshAdRequests = 4.9f;
const float kAdFlakeAdRequestTimeout = 10.0f;

NSInteger adNetworkPriorityComparer(id a, id b, void *ctx)
{
	AdFlakeAdNetworkConfig *acfg = a, *bcfg = b;
	if(acfg.priority < bcfg.priority)
	{
		return NSOrderedAscending;
	}
	else if(acfg.priority > bcfg.priority)
	{
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}


@implementation AdFlakeView

#pragma mark Properties getters/setters

@synthesize delegate;
@synthesize config;
@synthesize prioritizedAdNetCfgs;
@synthesize currAdapter;
@synthesize lastAdapter;
@synthesize currVideoAdapter;
@synthesize lastVideoAdapter;
@synthesize lastRequestTime;
@synthesize refreshTimer;
@synthesize lastError;
@synthesize showingModalView;
@synthesize configStore;
@synthesize rollOverReachability;
@synthesize testDarts;

- (void)setDelegate:(id <AdFlakeDelegate>)theDelegate {
	[self willChangeValueForKey:@"delegate"];
	delegate = theDelegate;
	if (self.currAdapter) {
		self.currAdapter.adFlakeDelegate = theDelegate;
	}
	if (self.lastAdapter) {
		self.lastAdapter.adFlakeDelegate = theDelegate;
	}if (self.currVideoAdapter) {
		self.currVideoAdapter.adFlakeDelegate = theDelegate;
	}
	if (self.lastVideoAdapter) {
		self.lastVideoAdapter.adFlakeDelegate = theDelegate;
	}
	[self didChangeValueForKey:@"delegate"];
}


#pragma mark Life cycle methods

+ (AdFlakeView *)requestAdFlakeViewWithDelegate:(id<AdFlakeDelegate>)delegate {
	if (![delegate respondsToSelector:
		  @selector(viewControllerForPresentingModalView)]) {
		[NSException raise:@"AdFlakeIncompleteDelegateException"
					format:@"AdFlakeDelegate must implement"
		 @" viewControllerForPresentingModalView"];
	}
	AdFlakeView *adView
    = [[[AdFlakeView alloc] initWithDelegate:delegate] autorelease];
	[adView startGetConfig];  // errors are communicated via delegate
	return adView;
}

- (id)initWithDelegate:(id<AdFlakeDelegate>)d {
	self = [super initWithFrame:kAdFlakeViewDefaultFrame];
	if (self != nil) {
		delegate = d;
		self.backgroundColor = [UIColor clearColor];
		// to prevent ugly artifacts if ad network banners are bigger than the
		// default frame
		self.clipsToBounds = YES;
		showingModalView = NO;
		appInactive = NO;

		// default config store. Can be overridden for testing
		self.configStore = [AdFlakeConfigStore sharedStore];
		
		usedVideoNetworkConfigs = [[NSMutableArray alloc] init];

		// get notified of app activity
		NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
		[notifCenter addObserver:self
						selector:@selector(resignActive:)
							name:UIApplicationWillResignActiveNotification
						  object:nil];
		[notifCenter addObserver:self
						selector:@selector(becomeActive:)
							name:UIApplicationDidBecomeActiveNotification
						  object:nil];

		// remember pending ad requests, so we don't make more than one
		// request per ad network at a time
		pendingAdapters = [[NSMutableDictionary alloc] initWithCapacity:30];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[rollOverReachability setDelegate:nil];
	[rollOverReachability release], rollOverReachability = nil;
	delegate = nil;
	[config removeDelegate:self];
	[config release], config = nil;
	[prioritizedAdNetCfgs release], prioritizedAdNetCfgs = nil;
	totalPercent = 0.0;
	requesting = NO;
	currAdapter.adFlakeDelegate = nil, currAdapter.adFlakeView = nil;
	[currAdapter release], currAdapter = nil;
	lastAdapter.adFlakeDelegate = nil, lastAdapter.adFlakeView = nil;
	[lastAdapter release], lastAdapter = nil;
	
	currVideoAdapter.adFlakeDelegate = nil, currVideoAdapter.adFlakeView = nil;
	[currVideoAdapter release], currVideoAdapter = nil;
	lastVideoAdapter.adFlakeDelegate = nil, lastVideoAdapter.adFlakeView = nil;
	[lastVideoAdapter release], lastVideoAdapter = nil;
	[lastRequestTime release], lastRequestTime = nil;
	[pendingAdapters release], pendingAdapters = nil;
	if (refreshTimer != nil) {
		[refreshTimer invalidate];
		[refreshTimer release], refreshTimer = nil;
	}
	[lastError release], lastError = nil;

	[usedVideoNetworkConfigs release], usedVideoNetworkConfigs = nil;
	
	[super dealloc];
}


#pragma mark Config and setup methods

static id<AdFlakeDelegate> classAdFlakeDelegateForConfig = nil;

+ (void)startPreFetchingConfigurationDataWithDelegate:
(id<AdFlakeDelegate>)delegate {
	if (classAdFlakeDelegateForConfig != nil) {
		AFLogWarn(@"Called startPreFetchingConfig when another fetch is"
				  @" in progress");
		return;
	}
	classAdFlakeDelegateForConfig = delegate;
	[[AdFlakeConfigStore sharedStore] getConfig:[delegate adFlakeApplicationKey]
									   delegate:(id<AdFlakeConfigDelegate>)self];
}

+ (void)updateAdFlakeConfigWithDelegate:(id<AdFlakeDelegate>)delegate {
	if (classAdFlakeDelegateForConfig != nil) {
		AFLogWarn(@"Called updateConfig when another fetch is in progress");
		return;
	}
	classAdFlakeDelegateForConfig = delegate;
	[[AdFlakeConfigStore sharedStore]
	 fetchConfig:[delegate adFlakeApplicationKey]
	 delegate:(id<AdFlakeConfigDelegate>)self];
}

- (void)startGetConfig {
	// Invalidate ad refresh timer as it may change with the new config
	if (self.refreshTimer) {
		[self.refreshTimer invalidate];
		self.refreshTimer = nil;
	}

	configFetchAttempts = 0;
	AdFlakeConfig *cfg = [configStore getConfig:[delegate adFlakeApplicationKey]
									   delegate:(id<AdFlakeConfigDelegate>)self];
	self.config = cfg;
}

- (void)attemptFetchConfig {
	AdFlakeConfig *cfg = [configStore
						  fetchConfig:[delegate adFlakeApplicationKey]
						  delegate:(id<AdFlakeConfigDelegate>)self];
	if (cfg != nil) {
		self.config = cfg;
	}
}

- (void)updateAdFlakeConfig {
	// Invalidate ad refresh timer as it may change with the new config
	if (self.refreshTimer) {
		[self.refreshTimer invalidate];
		self.refreshTimer = nil;
	}

	// Request new config
	AFLogDebug(@"======== Updating config ========");
	configFetchAttempts = 0;
	[self attemptFetchConfig];
}

#pragma mark Ads management private methods

- (void)buildPrioritizedAdNetCfgsAndMakeRequest {
	NSMutableArray *freshNetCfgs = [[NSMutableArray alloc] init];
	for (AdFlakeAdNetworkConfig *cfg in config.adNetworkConfigs) {
		// do not add the ad network in rotation if there's already a stray
		// pending ad request to this ad network (due to network outage or plain
		// slow request)
		NSNumber *netKey = [NSNumber numberWithInt:(int)cfg.networkType];
		if ([pendingAdapters objectForKey:netKey] == nil) {
			[freshNetCfgs addObject:cfg];
		}
		else {
			AFLogDebug(@"Already has pending ad request for network type %d,"
					   @" not adding ad network config %@",
					   cfg.networkType, cfg);
		}
	}
	[freshNetCfgs sortUsingFunction:adNetworkPriorityComparer context:nil];
	totalPercent = 0.0;
	for (AdFlakeAdNetworkConfig *cfg in freshNetCfgs) {
		totalPercent += cfg.trafficPercentage;
	}
	self.prioritizedAdNetCfgs = freshNetCfgs;
	[freshNetCfgs release];

	[self makeAdRequest:YES];
}

static BOOL randSeeded = NO;

- (double)nextRandom
{
	if (!randSeeded) {
		srandom(CFAbsoluteTimeGetCurrent());
		randSeeded = YES;
	}
	return ((double)(random()-1)/RAND_MAX);
}

- (double)nextDart {
	if (testDarts != nil) {
		if (testDartIndex >= [testDarts count]) {
			testDartIndex = 0;
		}
		NSNumber *nextDartNum = [testDarts objectAtIndex:testDartIndex];
		double dart = [nextDartNum doubleValue];
		if (dart >= totalPercent) {
			dart = totalPercent - 0.001;
		}
		testDartIndex++;
		return dart;
	}
	else {
		return [self nextRandom] * totalPercent;
	}
}

- (AdFlakeAdNetworkConfig *)nextNetworkCfgByPercent {
	if ([prioritizedAdNetCfgs count] == 0) {
		return nil;
	}

	double dart = [self nextDart];

	double tempTotal = 0.0;

	AdFlakeAdNetworkConfig *result = nil;
	for (AdFlakeAdNetworkConfig *network in prioritizedAdNetCfgs) {
		result = network; // make sure there is always a network chosen
		tempTotal += network.trafficPercentage;
		if (dart < tempTotal) {
			// this is the one to use.
			break;
		}
	}

	AFLogDebug(@">>>> By Percent chosen %@ (%@), dart %lf in %lf",
			   result.nid, result.networkName, dart, totalPercent);
	return result;
}

- (AdFlakeAdNetworkConfig *)nextNetworkCfgByPriority {
	if ([prioritizedAdNetCfgs count] == 0) {
		return nil;
	}
	AdFlakeAdNetworkConfig *result = [prioritizedAdNetCfgs objectAtIndex:0];
	AFLogDebug(@">>>> By Priority chosen %@ (%@)",
			   result.nid, result.networkName);
	return result;
}

- (void)makeAdRequest:(BOOL)isFirstRequest {
	if ([prioritizedAdNetCfgs count] == 0) {
		// ran out of ad networks
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoMoreAdNetworks
								description:@"No more ad networks to roll over"];
		return;
	}

	if (showingModalView) {
		AFLogDebug(@"Modal view is active, not going to request another ad");
		return;
	}
	[self.rollOverReachability setDelegate:nil];
	self.rollOverReachability = nil;  // stop any roll over reachability checks

	if (requesting) {
		// it is OK to request a new one while another one is in progress
		// the adapter callbacks from the old adapter will be ignored.
		// User-initiated request ad will be blocked in requestFreshAd.
		AFLogDebug(@"Already requesting ad, will request a new one.");
	}
	requesting = YES;

	AdFlakeAdNetworkConfig *nextAdNetCfg = nil;

	if (isFirstRequest && totalPercent > 0.0) {
		nextAdNetCfg = [self nextNetworkCfgByPercent];
	}
	else {
		nextAdNetCfg = [self nextNetworkCfgByPriority];
	}
	if (nextAdNetCfg == nil) {
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoMoreAdNetworks
								description:@"No more ad networks to request"];
		return;
	}

	AdFlakeAdNetworkAdapter *adapter =
    [[nextAdNetCfg.adapterClass alloc] initWithAdFlakeDelegate:delegate
														  view:self
														config:config
												 networkConfig:nextAdNetCfg];
	// keep the last adapter around to catch stale ad network delegate calls
	// during transitions
	self.lastAdapter = self.currAdapter;
	self.currAdapter = adapter;
	[adapter release];

	// take nextAdNetCfg out so we don't request again when we roll over
	[prioritizedAdNetCfgs removeObject:nextAdNetCfg];

	if (lastRequestTime) {
		[lastRequestTime release];
	}
	lastRequestTime = [[NSDate date] retain];

	// remember this pending request so we do not request again when we make
	// new ad requests
	NSNumber *netTypeKey = [NSNumber numberWithInt:(int)nextAdNetCfg.networkType];
	[pendingAdapters setObject:currAdapter forKey:netTypeKey];

	// If last adapter is of the same network type, make the last adapter stop
	// being an ad network view delegate to prevent the last adapter from calling
	// back to this AdFlakeView during the transition and afterwards.
	// We should not do this for all adapters, because if the last adapter is
	// still in progress, we need to know about it in the adapter callbacks.
	// That the last adapter is the same type as the new adapter is possible only
	// if the last ad request finished, i.e. called back to its adapters. There
	// are cases, e.g. iAd, when the ad network may call back multiple times,
	// because of internal refreshes.
	if (self.lastAdapter.networkConfig.networkType ==
		self.currAdapter.networkConfig.networkType) {
		[self.lastAdapter stopBeingDelegate];
	}

	[currAdapter getAd];
}

- (BOOL)canRefresh {
	return !(ignoreNewAdRequests
			 || ignoreAutoRefreshTimer
			 || appInactive
			 || showingModalView);
}

- (void)timerRequestFreshAd {
	if (![self canRefresh]) {
		AFLogDebug(@"Not going to refresh due to flags, app not active or modal");
		return;
	}
	if (lastRequestTime != nil) {
		NSTimeInterval sinceLast = -[lastRequestTime timeIntervalSinceNow];
		if (sinceLast <= kAdFlakeMinimumTimeBetweenFreshAdRequests) {
			AFLogDebug(@"Ad refresh timer fired too soon after last ad request,"
					   @" ignoring");
			return;
		}
	}
	AFLogDebug(@"======== Refreshing ad due to timer ========");
	[self buildPrioritizedAdNetCfgsAndMakeRequest];
}

#pragma mark Ads management public methods

- (void)requestAndPresentVideoAdModalWithNetworkConfig:(AdFlakeAdNetworkConfig*)videoNetworkConfig
{
	if (videoNetworkConfig == nil) {
		if ([delegate respondsToSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:)])
		{
			[delegate performSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:) withObject:self];
		}
		return;
	}
	
	AdFlakeAdNetworkAdapter *adapter = [[videoNetworkConfig.adapterClass alloc] initWithAdFlakeDelegate:delegate
																								   view:self
																								 config:config
																						  networkConfig:videoNetworkConfig];
	// keep the last adapter around to catch stale ad network delegate calls
	// during transitions
	self.lastVideoAdapter = self.currVideoAdapter;
	self.currVideoAdapter = adapter;
	[adapter release];
	
	[usedVideoNetworkConfigs addObject:videoNetworkConfig];
	
	// If last adapter is of the same network type, make the last adapter stop
	// being an ad network view delegate to prevent the last adapter from calling
	// back to this AdFlakeView during the transition and afterwards.
	// We should not do this for all adapters, because if the last adapter is
	// still in progress, we need to know about it in the adapter callbacks.
	// That the last adapter is the same type as the new adapter is possible only
	// if the last ad request finished, i.e. called back to its adapters. There
	// are cases, e.g. iAd, when the ad network may call back multiple times,
	// because of internal refreshes.
	if (self.lastVideoAdapter.networkConfig.networkType == self.currVideoAdapter.networkConfig.networkType) {
		[self.lastVideoAdapter stopBeingDelegate];
	}
	
	[self.currVideoAdapter getAd];
}

- (void)requestAndPresentVideoAdModal
{
	// only make request in main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(requestAndPresentVideoAdModal)
							   withObject:nil
							waitUntilDone:NO];
		return;
	}
	
	if (config.videoAdsAreOff || showingModalView || !config) {
		if ([delegate respondsToSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:)])
		{
			[delegate performSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:) withObject:self];
		}
		return;
	}
	
	[usedVideoNetworkConfigs removeAllObjects];
	// for interstitials we just dart a random interstitial each time
	double currentRandom = 0.0;
	double actualPercent = 0.0;
	double dart = 0.0;
	bool didRetryDart = false;
	
	for (AdFlakeAdNetworkConfig *networkConfig in self.config.videoAdNetworkConfigs)
	{
//		if (networkConfig.trafficPercentage == 0.0f)
//		{
//			[usedVideoNetworkConfigs addObject:networkConfig];
//			continue;
//		}
		
		actualPercent += networkConfig.trafficPercentage;
	}
retryDart:
	dart = [self nextRandom] * actualPercent;
	currentRandom = 0.0;
	AFLogDebug(@"video dart=%f", dart);

	AdFlakeAdNetworkConfig *videoNetworkConfig = nil;
	for (AdFlakeAdNetworkConfig *networkConfig in self.config.videoAdNetworkConfigs)
	{
		if ([usedVideoNetworkConfigs containsObject:networkConfig])
			continue;
	
		if (dart >= currentRandom && dart <= currentRandom + networkConfig.trafficPercentage)
		{
			// we hit this network
			AFLogDebug(@"using network=%@", networkConfig);
			videoNetworkConfig = networkConfig;
			break;
		}
		
		currentRandom += networkConfig.trafficPercentage;
		
		AFLogDebug(@"config=%@", networkConfig);
	}
	
	// reduce the chance of the same network playing twice
	if (!didRetryDart && currVideoAdapter != nil && currVideoAdapter.networkConfig.networkType == videoNetworkConfig.networkType)
	{
		didRetryDart = true;
		goto retryDart;
	}
	
	[self requestAndPresentVideoAdModalWithNetworkConfig:videoNetworkConfig];
}

- (void)tryRequestNextVideoAdModal
{
	// only make request in main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(tryRequestNextVideoAdModal)
							   withObject:nil
							waitUntilDone:NO];
		return;
	}
	
	if (usedVideoNetworkConfigs.count == 0 ||
		usedVideoNetworkConfigs.count == self.config.videoAdNetworkConfigs.count)
	{
		// failed
		if ([delegate respondsToSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:)])
		{
			[delegate performSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:) withObject:self];
		}
		return;
	}
	
	// for interstitials we just dart a random interstitial each time
	double currentRandom = 0.0f;
	double actualPercent = 0.0;
	
	for (AdFlakeAdNetworkConfig *cfg in self.config.videoAdNetworkConfigs) {
		
		// skip already used network configs
		if ([usedVideoNetworkConfigs containsObject:cfg])
			continue;
		
		actualPercent += cfg.trafficPercentage;
	}
	const double dart = [self nextRandom] * actualPercent;
	
	AFLogDebug(@"video dart=%f", dart);
	
	AdFlakeAdNetworkConfig *videoNetworkConfig = nil;
	
	for (AdFlakeAdNetworkConfig *networkConfig in self.config.videoAdNetworkConfigs) {
		
		// skip already used network configs
		if ([usedVideoNetworkConfigs containsObject:networkConfig])
			continue;
		
		if (dart >= currentRandom && dart <= currentRandom + networkConfig.trafficPercentage)
		{
			// we hit this network
			AFLogDebug(@"using network=%@", networkConfig);
			videoNetworkConfig = networkConfig;
			break;
		}
		
		currentRandom += networkConfig.trafficPercentage;
		
		AFLogDebug(@"config=%@", networkConfig);
	}
	
	if (videoNetworkConfig == nil)
	{
		// failed
		if ([delegate respondsToSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:)])
		{
			[delegate performSelector:@selector(adFlakeDidFailToRequestAndPresentVideoAdModal:) withObject:self];
		}
		return;
	}
	
	[self requestAndPresentVideoAdModalWithNetworkConfig:videoNetworkConfig];
}

- (void)requestFreshAd {
	// only make request in main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(requestFreshAd)
							   withObject:nil
							waitUntilDone:NO];
		return;
	}
	if (ignoreNewAdRequests) {
		// don't request new ad
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestIgnoredError
								description:@"ignoreNewAdRequests flag set"];
		return;
	}
	if (requesting) {
		// don't request if there's a request outstanding
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestInProgressError
								description:@"Ad request already in progress"];
		return;
	}
	if (showingModalView) {
		// don't request if there's a modal view active
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestModalActiveError
								description:@"Modal view active"];
		return;
	}
	if (!config) {
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoConfigError
								description:@"No ad configuration"];
		return;
	}
	if (lastRequestTime != nil) {
		NSTimeInterval sinceLast = -[lastRequestTime timeIntervalSinceNow];
		if (sinceLast <= kAdFlakeMinimumTimeBetweenFreshAdRequests) {
			NSString *desc
			= [NSString stringWithFormat:
			   @"Requesting fresh ad too soon! It has been only %lfs. Minimum %lfs",
			   sinceLast, kAdFlakeMinimumTimeBetweenFreshAdRequests];
			[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestTooSoonError
									description:desc];
			return;
		}
	}
	[self buildPrioritizedAdNetCfgsAndMakeRequest];
}

- (void)rollOver {
	if (ignoreNewAdRequests) {
		return;
	}
	// only make request in main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(rollOver)
							   withObject:nil
							waitUntilDone:NO];
		return;
	}
	[self makeAdRequest:NO];
}

- (BOOL)adExists {
	UIView *currAdView = [self viewWithTag:kAdFlakeViewAdSubViewTag];
	return currAdView != nil;
}

- (NSString *)mostRecentNetworkName {
	if (currAdapter == nil) return nil;
	return currAdapter.networkConfig.networkName;
}

- (void)ignoreAutoRefreshTimer {
	ignoreAutoRefreshTimer = YES;
}

- (void)doNotIgnoreAutoRefreshTimer {
	ignoreAutoRefreshTimer = NO;
}

- (BOOL)isIgnoringAutoRefreshTimer {
	return ignoreAutoRefreshTimer;
}

- (void)ignoreNewAdRequests {
	ignoreNewAdRequests = YES;
}

- (void)doNotIgnoreNewAdRequests {
	ignoreNewAdRequests = NO;
}

- (BOOL)isIgnoringNewAdRequests {
	return ignoreNewAdRequests;
}


#pragma mark Stats reporting methods

- (void)metricPing:(NSURL *)endPointBaseURL
               nid:(NSString *)nid
           netType:(AdFlakeAdNetworkType)type {
	// use config.appKey not from [delegate adFlakeApplicationKey] as delegate
	// can be niled out at this point. Attempt at Issue #42 .
	NSString *query = [NSString stringWithFormat:
					   @"?appid=%@&nid=%@&type=%d&country_code=%@&appver=%d&client=1",
					   config.appKey,
					   nid,
					   type,
					   [[NSLocale currentLocale] localeIdentifier],
					   kAdFlakeAppClientVersion];
	NSURL *metURL = [NSURL URLWithString:query
						   relativeToURL:endPointBaseURL];
	AFLogDebug(@"Sending metric ping to %@", metURL);
	NSURLRequest *metRequest = [NSURLRequest requestWithURL:metURL];
	[NSURLConnection connectionWithRequest:metRequest
								  delegate:nil]; // fire and forget
}

- (void)reportExImpression:(NSString *)nid netType:(AdFlakeAdNetworkType)type {
	NSURL *baseURL = nil;
	if ([delegate respondsToSelector:@selector(adFlakeImpMetricURL)]) {
		baseURL = [delegate adFlakeImpMetricURL];
	}
	if (baseURL == nil) {
		baseURL = [NSURL URLWithString:kAdFlakeDefaultImpMetricURL];
	}
	[self metricPing:baseURL nid:nid netType:type];
}

- (void)reportExClick:(NSString *)nid netType:(AdFlakeAdNetworkType)type {
	NSURL *baseURL = nil;
	if ([delegate respondsToSelector:@selector(adFlakeClickMetricURL)]) {
		baseURL = [delegate adFlakeClickMetricURL];
	}
	if (baseURL == nil) {
		baseURL = [NSURL URLWithString:kAdFlakeDefaultClickMetricURL];
	}
	[self metricPing:baseURL nid:nid netType:type];
}


#pragma mark UI methods

- (CGSize)actualAdSize {
	if (currAdapter == nil || currAdapter.adNetworkView == nil)
		return kAdFlakeViewDefaultSize;
	return currAdapter.adNetworkView.frame.size;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
	if (currAdapter == nil) return;
	[currAdapter rotateToOrientation:orientation];
}

- (void)transitionToView:(UIView *)view {
	UIView *currAdView = [self viewWithTag:kAdFlakeViewAdSubViewTag];
	if (view == currAdView) {
		AFLogDebug(@"ignoring ad transition to itself");
		return; // no need to transition to itself
	}
	view.tag = kAdFlakeViewAdSubViewTag;
	if (currAdView) {
		// swap
		currAdView.tag = 0;

		AFBannerAnimationType animType;
		if (config.bannerAnimationType == AFBannerAnimationTypeRandom) {
			if (!randSeeded) {
				srandom(CFAbsoluteTimeGetCurrent());
			}
			// range is 1 to 7, inclusive
			animType = (random() % 7) + 1;
			AFLogDebug(@"Animation type chosen by random is %d", animType);
		}
		else {
			animType = config.bannerAnimationType;
		}
		if (![currAdapter isBannerAnimationOK:animType]) {
			animType = AFBannerAnimationTypeNone;
		}

		if (animType == AFBannerAnimationTypeNone) {
			[currAdView removeFromSuperview];
			[self addSubview:view];
			if ([delegate respondsToSelector:
				 @selector(adFlakeDidAnimateToNewAdIn:)]) {
				// no animation, callback right away
				[(NSObject *)delegate
				 performSelectorOnMainThread:@selector(adFlakeDidAnimateToNewAdIn:)
				 withObject:self
				 waitUntilDone:NO];
			}
		}
		else {
			switch (animType) {
				case AFBannerAnimationTypeSlideFromLeft:
				{
					CGRect f = view.frame;
					f.origin.x = -f.size.width;
					view.frame = f;
					[self addSubview:view];
					break;
				}
				case AFBannerAnimationTypeSlideFromRight:
				{
					CGRect f = view.frame;
					f.origin.x = self.frame.size.width;
					view.frame = f;
					[self addSubview:view];
					break;
				}
				case AFBannerAnimationTypeFadeIn:
					view.alpha = 0;
					[self addSubview:view];
					break;
				default:
					// no setup required for other animation types
					break;
			}

			[currAdView retain]; // will be released when animation is done
			AFLogDebug(@"Beginning AdFlakeAdTransition animation"
					   @" currAdView %x incoming %x", currAdView, view);
			[UIView beginAnimations:@"AdFlakeAdTransition" context:currAdView];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:
			 @selector(newAdAnimationDidStopWithAnimationID:finished:context:)];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:1.0];
			// cache has to set to NO because of VideoEgg
			switch (animType) {
				case AFBannerAnimationTypeFlipFromLeft:
					[self addSubview:view];
					[currAdView removeFromSuperview];
					[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
										   forView:self
											 cache:NO];
					break;
				case AFBannerAnimationTypeFlipFromRight:
					[self addSubview:view];
					[currAdView removeFromSuperview];
					[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
										   forView:self
											 cache:NO];
					break;
				case AFBannerAnimationTypeCurlUp:
					[self addSubview:view];
					[currAdView removeFromSuperview];
					[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
										   forView:self
											 cache:NO];
					break;
				case AFBannerAnimationTypeCurlDown:
					[self addSubview:view];
					[currAdView removeFromSuperview];
					[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
										   forView:self
											 cache:NO];
					break;
				case AFBannerAnimationTypeSlideFromLeft:
				case AFBannerAnimationTypeSlideFromRight:
				{
					CGRect f = view.frame;
					f.origin.x = 0;
					view.frame = f;
					break;
				}
				case AFBannerAnimationTypeFadeIn:
					view.alpha = 1.0;
					break;
				default:
					[self addSubview:view];
					[currAdView removeFromSuperview];
					AFLogWarn(@"Unrecognized Animation type: %d", animType);
					break;
			}
			[UIView commitAnimations];
		}
	}
	else {  // currAdView
		// new
		[self addSubview:view];
		if ([delegate respondsToSelector:@selector(adFlakeDidAnimateToNewAdIn:)]) {
			// no animation, callback right away
			[(NSObject *)delegate
			 performSelectorOnMainThread:@selector(adFlakeDidAnimateToNewAdIn:)
			 withObject:self
			 waitUntilDone:NO];
		}
	}
}

- (void)replaceBannerViewWith:(UIView*)bannerView {
	[self transitionToView:bannerView];
}

// Called at the end of the new ad animation; we use this opportunity to do
// memory management cleanup. See the comment in adDidLoad:.
- (void)newAdAnimationDidStopWithAnimationID:(NSString *)animationID
                                    finished:(BOOL)finished
                                     context:(void *)context
{
	AFLogDebug(@"animation %@ finished %@ context %x",
			   animationID, finished? @"YES":@"NO", context);
	UIView *adViewToRemove = (UIView *)context;
	[adViewToRemove removeFromSuperview];
	[adViewToRemove release]; // was retained before beginAnimations
	lastAdapter.adFlakeDelegate = nil, lastAdapter.adFlakeView = nil;
	self.lastAdapter = nil;
	if ([delegate respondsToSelector:@selector(adFlakeDidAnimateToNewAdIn:)]) {
		[delegate adFlakeDidAnimateToNewAdIn:self];
	}
}


#pragma mark UIView touch methods

- (BOOL)_isEventATouch30:(UIEvent *)event {
	if ([event respondsToSelector:@selector(type)]) {
		return event.type == UIEventTypeTouches;
	}
	return YES; // UIEvent in 2.2.1 has no type property, so assume yes.
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	BOOL itsInside = [super pointInside:point withEvent:event];
	if (itsInside && currAdapter != nil && lastNotifyAdapter != currAdapter
		&& [self _isEventATouch30:event]
		&& [currAdapter shouldSendExMetric]) {
		lastNotifyAdapter = currAdapter;
		[self reportExClick:currAdapter.networkConfig.nid
					netType:currAdapter.networkConfig.networkType];
	}
	return itsInside;
}


#pragma mark UIView methods

- (void)willMoveToSuperview:(UIView *)newSuperview {
	if (newSuperview == nil) {
		[refreshTimer invalidate];
		self.refreshTimer = nil;
	}
}


#pragma mark - Adapter callbacks

// Chores that are common to all adapter callbacks
- (void)adRequestReturnsForAdapter:(AdFlakeAdNetworkAdapter *)adapter {
	// no longer pending. Need to retain and autorelease the adapter
	// since the adapter may not be retained anywhere else other than the pending
	// dict
	NSNumber *netTypeKey
    = [NSNumber numberWithInt:(int)adapter.networkConfig.networkType];
	AdFlakeAdNetworkAdapter *pendingAdapter
    = [pendingAdapters objectForKey:netTypeKey];
	if (pendingAdapter != nil) {
		if (pendingAdapter != adapter) {
			// Possible if the ad refreshes itself and sends callbacks doing so, while
			// a new ad of the same network is pending (e.g. iAd)
			AFLogError(@"Stored pending adapter %@ for network type %@ is different"
					   @" from the one sending the adapter callback %@",
					   pendingAdapter,
					   netTypeKey,
					   adapter);
		}
		[[pendingAdapter retain] autorelease];
		[pendingAdapters removeObjectForKey:netTypeKey];
	}
}

#pragma mark Video Ads

- (void)adapterUserWatchedEntireVideoAdModal:(AdFlakeAdNetworkAdapter *)adapter
{
	AFLogDebug(@"User watched entire video ad from adapter (nid %@)", adapter.networkConfig.nid);

	
	if ([delegate respondsToSelector:@selector(adFlakeUserDidWatchEntireVideoAdModal:)])
	{
		[delegate performSelector:@selector(adFlakeUserDidWatchEntireVideoAdModal:) withObject:self];
	}
}

- (void)adapterDidReceiveVideoAd:(AdFlakeAdNetworkAdapter *)adapter
{
	AFLogDebug(@"Received ad from adapter (nid %@)", adapter.networkConfig.nid);
	
	// remove all configs
	[usedVideoNetworkConfigs removeAllObjects];
	
	if ([delegate respondsToSelector:@selector(adFlakeWillPresentVideoAdModal:)])
	{
		[delegate performSelector:@selector(adFlakeWillPresentVideoAdModal:) withObject:self];
	}
	// report impression. No need to notify delegate because delegate is notified
	// via Generic Notification or event.
	if ([adapter shouldSendExMetric]) {
		[self reportExImpression:adapter.networkConfig.nid
						 netType:adapter.networkConfig.networkType];
	}
}

- (void)adapter:(AdFlakeAdNetworkAdapter *)adapter didFailVideoAd:(NSError *)error
{
	AFLogDebug(@"Failed to receive ad from adapter (nid %@): %@",
			   adapter.networkConfig.nid, error);
	
	// try to roll over
	[self tryRequestNextVideoAdModal];
}

#pragma mark Banner Ads

- (void)adapter:(AdFlakeAdNetworkAdapter *)adapter
didReceiveAdView:(UIView *)view {
	[self adRequestReturnsForAdapter:adapter];
	if (adapter != currAdapter) {
		AFLogDebug(@"Received didReceiveAdView from a stale adapter %@", adapter);
		return;
	}
	AFLogDebug(@"Received ad from adapter (nid %@)", adapter.networkConfig.nid);

	// UIView operations should be performed on main thread
	[self performSelectorOnMainThread:@selector(transitionToView:)
						   withObject:view
						waitUntilDone:NO];
	requesting = NO;

	// report impression and notify delegate
	if ([adapter shouldSendExMetric]) {
		[self reportExImpression:adapter.networkConfig.nid
						 netType:adapter.networkConfig.networkType];
	}
	if ([delegate respondsToSelector:@selector(adFlakeDidReceiveAd:)]) {
		[delegate adFlakeDidReceiveAd:self];
	}
}

- (void)adapter:(AdFlakeAdNetworkAdapter *)adapter didFailAd:(NSError *)error {
	[self adRequestReturnsForAdapter:adapter];
	if (adapter != currAdapter) {
		AFLogDebug(@"Received didFailAd from a stale adapter %@: %@",
				   adapter, error);
		return;
	}
	AFLogDebug(@"Failed to receive ad from adapter (nid %@): %@",
			   adapter.networkConfig.nid, error);
	requesting = NO;

	if ([prioritizedAdNetCfgs count] == 0) {
		// we have run out of networks to try and need to error out.
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoMoreAdNetworks
								description:@"No more ad networks to roll over"];
		return;
	}

	// try to roll over, but before we do, check to see if the failure is because
	// network has gotten unreachable. If so, don't roll over. Use www.google.com
	// as test, assuming www.google.com itself is always up if there's network.
	self.rollOverReachability  = [AFNetworkReachabilityWrapper reachabilityWithHostname:@"www.google.com"
																	   callbackDelegate:self];
	if (self.rollOverReachability == nil) {
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoNetworkError
								description:@"Failed network reachability test"];
		return;
	}
	if (![self.rollOverReachability scheduleInCurrentRunLoop]) {
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoNetworkError
								description:@"Failed network reachability test"];
		return;
	}
}

- (void)adapterDidFinishAdRequest:(AdFlakeAdNetworkAdapter *)adapter {
	[self adRequestReturnsForAdapter:adapter];
	if (adapter != currAdapter) {
		AFLogDebug(@"Received adapterDidFinishAdRequest from a stale adapter");
		return;
	}
	// view is supplied via other mechanism (e.g. Generic Notification or Event)
	requesting = NO;

	// report impression. No need to notify delegate because delegate is notified
	// via Generic Notification or event.
	if ([adapter shouldSendExMetric]) {
		[self reportExImpression:adapter.networkConfig.nid
						 netType:adapter.networkConfig.networkType];
	}
}


#pragma mark AFNetworkReachabilityDelegate methods

- (void)reachabilityNotReachable:(AFNetworkReachabilityWrapper *)reach {
	if (reach == self.rollOverReachability) {
		[self.rollOverReachability setDelegate:nil];
		self.rollOverReachability = nil;  // release it and unschedule
		[self notifyDelegateOfErrorWithCode:AdFlakeAdRequestNoNetworkError
								description:@"No network connection for rollover"];
		return;
	}
	AFLogWarn(@"Unrecognized reachability called not reachable %s:%d",
			  __FILE__, __LINE__);
}

- (void)reachabilityBecameReachable:(AFNetworkReachabilityWrapper *)reach {
	if (reach == self.rollOverReachability) {
		// not an error, just need to rollover
		[lastError release], lastError = nil;
		if ([delegate respondsToSelector:
			 @selector(adFlakeDidFailToReceiveAd:usingBackup:)]) {
			[delegate adFlakeDidFailToReceiveAd:self usingBackup:YES];
		}
		[self.rollOverReachability setDelegate:nil];
		self.rollOverReachability = nil;   // release it and unschedule
		[self rollOver];
		return;
	}
	AFLogWarn(@"Unrecognized reachability called reachable %s:%d",
			  __FILE__, __LINE__);
}


#pragma mark AdFlakeConfigDelegate methods

+ (NSURL *)adFlakeConfigURL {
	if (classAdFlakeDelegateForConfig != nil
		&& [classAdFlakeDelegateForConfig respondsToSelector:
			@selector(adFlakeConfigURL)]) {
			return [classAdFlakeDelegateForConfig adFlakeConfigURL];
		}
	return nil;
}

+ (void)adFlakeConfigDidReceiveConfig:(AdFlakeConfig *)config {
	AFLogDebug(@"Fetched Ad network config: %@", config);
	if (classAdFlakeDelegateForConfig != nil
		&& [classAdFlakeDelegateForConfig respondsToSelector:
			@selector(adFlakeDidReceiveConfig:)]) {
			[classAdFlakeDelegateForConfig adFlakeDidReceiveConfig:nil];
		}
	classAdFlakeDelegateForConfig = nil;
}

+ (void)adFlakeConfigDidFail:(AdFlakeConfig *)cfg error:(NSError *)error {
	AFLogError(@"Failed pre-fetching AdFlake config: %@", error);
	classAdFlakeDelegateForConfig = nil;
}

- (void)adFlakeConfigDidReceiveConfig:(AdFlakeConfig *)cfg {
	if (self.config != cfg) {
		AFLogWarn(@"AdFlakeView: getting adFlakeConfigDidReceiveConfig callback"
				  @" from unknown AdFlakeConfig object");
		return;
	}
	AFLogDebug(@"Fetched Ad network config: %@", cfg);
	if ([delegate respondsToSelector:@selector(adFlakeDidReceiveConfig:)]) {
		[delegate adFlakeDidReceiveConfig:self];
	}
	
	if (cfg.videoAdsAreOff)
	{
		if ([delegate respondsToSelector:
			 @selector(adFlakeReceivedNotificationVideoAdsAreOff:)]) {
			// to prevent self being freed before this returns, in case the
			// delegate decides to release this
			[self retain];
			[delegate adFlakeReceivedNotificationVideoAdsAreOff:self];
			[self autorelease];
		}
	}
	
	if (cfg.adsAreOff) {
		if ([delegate respondsToSelector:
			 @selector(adFlakeReceivedNotificationAdsAreOff:)]) {
			// to prevent self being freed before this returns, in case the
			// delegate decides to release this
			[self retain];
			[delegate adFlakeReceivedNotificationAdsAreOff:self];
			[self autorelease];
		}
		return;
	}

	// Perform ad network data structure build and request in main thread
	// to avoid contention
	[self performSelectorOnMainThread:
	 @selector(buildPrioritizedAdNetCfgsAndMakeRequest)
						   withObject:nil
						waitUntilDone:NO];

	// Setup recurring timer for ad refreshes, if required
	if (config.refreshInterval > kAdFlakeMinimumTimeBetweenFreshAdRequests) {
		self.refreshTimer
		= [NSTimer scheduledTimerWithTimeInterval:config.refreshInterval
										   target:self
										 selector:@selector(timerRequestFreshAd)
										 userInfo:nil
										  repeats:YES];
	}
}

- (void)adFlakeConfigDidFail:(AdFlakeConfig *)cfg error:(NSError *)error {
	if (self.config != nil && self.config != cfg) {
		// self.config could be nil if this is called before init is finished
		AFLogWarn(@"AdFlakeView: getting adFlakeConfigDidFail callback from unknown"
				  @" AdFlakeConfig object");
		return;
	}
	configFetchAttempts++;
	if (configFetchAttempts < 3) {
		// schedule in run loop to avoid recursive calls to this function
		[self performSelectorOnMainThread:@selector(attemptFetchConfig)
							   withObject:self
							waitUntilDone:NO];
	}
	else {
		AFLogError(@"Failed fetching AdFlake config: %@", error);
		[self notifyDelegateOfError:error];
	}
}

- (NSURL *)adFlakeConfigURL {
	if ([delegate respondsToSelector:@selector(adFlakeConfigURL)]) {
		return [delegate adFlakeConfigURL];
	}
	return nil;
}


#pragma mark Active status notification callbacks

- (void)resignActive:(NSNotification *)notification {
	AFLogDebug(@"App become inactive, AdFlakeView will stop requesting ads");
	appInactive = YES;
}

- (void)becomeActive:(NSNotification *)notification {
	AFLogDebug(@"App become active, AdFlakeView will resume requesting ads");
	appInactive = NO;
}


#pragma mark AdFlakeDelegate helper methods

- (void)notifyDelegateOfErrorWithCode:(NSInteger)errorCode
                          description:(NSString *)desc {
	NSError *error = [[AdFlakeError alloc] initWithCode:errorCode
											description:desc];
	[self notifyDelegateOfError:error];
	[error release];
}

- (void)notifyDelegateOfError:(NSError *)error {
	[error retain];
	[lastError release];
	lastError = error;
	if ([delegate respondsToSelector:
		 @selector(adFlakeDidFailToReceiveAd:usingBackup:)]) {
		// to prevent self being freed before this returns, in case the
		// delegate decides to release this
		[self retain];
		[delegate adFlakeDidFailToReceiveAd:self usingBackup:NO];
		[self autorelease];
	}
}

@end
