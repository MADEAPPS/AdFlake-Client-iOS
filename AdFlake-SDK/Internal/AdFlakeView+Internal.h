/**
 * AdFlakeView+Internal.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeView+Internal.h
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

#import "AdFlakeAdNetworkAdapter.h"


@class AdFlakeConfigStore;


@interface AdFlakeView ()

// Only initializes default values for member variables
- (id)initWithDelegate:(id<AdFlakeDelegate>)delegate;

// Kicks off getting config from AdFlakeConfigStore
- (void)startGetConfig;

- (void)buildPrioritizedAdNetCfgsAndMakeRequest;
- (AdFlakeAdNetworkConfig *)nextNetworkCfgByPercent;
- (AdFlakeAdNetworkConfig *)nextNetworkCfgByPriority;
- (void)makeAdRequest:(BOOL)isFirstRequest;
- (void)reportExImpression:(NSString *)nid netType:(AdFlakeAdNetworkType)type;
- (void)reportExClick:(NSString *)nid netType:(AdFlakeAdNetworkType)type;
- (BOOL)canRefresh;
- (void)resignActive:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;

- (void)notifyDelegateOfErrorWithCode:(NSInteger)errorCode
                          description:(NSString *)desc;
- (void)notifyDelegateOfError:(NSError *)error;

@property (retain) AdFlakeConfig *config;
@property (retain) NSMutableArray *prioritizedAdNetCfgs;
@property (nonatomic,retain) AdFlakeAdNetworkAdapter *currAdapter;
@property (nonatomic,retain) AdFlakeAdNetworkAdapter *lastAdapter;
@property (nonatomic,retain) NSDate *lastRequestTime;
@property (nonatomic,retain) NSTimer *refreshTimer;
@property (nonatomic) BOOL showingModalView;
@property (nonatomic,assign) AdFlakeConfigStore *configStore;
@property (nonatomic,retain) AFNetworkReachabilityWrapper *rollOverReachability;
@property (nonatomic,retain) NSArray *testDarts;

@end
