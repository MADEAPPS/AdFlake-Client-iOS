/**
 * AdNetwork.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdNetwork.h
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
#import "AdFlakeDelegateProtocol.h"

#define AFAdNetworkConfigKeyType      @"type"
#define AFAdNetworkConfigKeyNID       @"nid"
#define AFAdNetworkConfigKeyName      @"nname"
#define AFAdNetworkConfigKeyWeight    @"weight"
#define AFAdNetworkConfigKeyPriority  @"priority"
#define AFAdNetworkConfigKeyCred      @"key"

@class AdFlakeError;
@class AdFlakeAdNetworkRegistry;

@interface AdFlakeAdNetworkConfig : NSObject {
	NSInteger networkType;
	NSString *nid;
	NSString *networkName;
	double trafficPercentage;
	NSInteger priority;
	NSDictionary *credentials;
	Class adapterClass;
}

- (id)initWithDictionary:(NSDictionary *)adNetConfigDict
       adNetworkRegistry:(AdFlakeAdNetworkRegistry *)registry
                   error:(AdFlakeError **)error;

@property (nonatomic,readonly) NSInteger networkType;
@property (nonatomic,readonly) NSString *nid;
@property (nonatomic,readonly) NSString *networkName;
@property (nonatomic,readonly) double trafficPercentage;
@property (nonatomic,readonly) NSInteger priority;
@property (nonatomic,readonly) NSDictionary *credentials;
@property (nonatomic,readonly) NSString *pubId;
@property (nonatomic,readonly) Class adapterClass;

@end


@interface UIColor (AdFlakeConfig)

- (id)initWithDict:(NSDictionary *)dict;

@end