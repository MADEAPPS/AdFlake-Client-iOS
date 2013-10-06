/**
 * AdFlakeAdapterNexage.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterNexage.h
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

#import "AdFlakeConfiguration.h"

#if defined(AdFlake_Enable_SDK_Nexage)

#import <Foundation/Foundation.h>
#import "AdFlakeAdNetworkAdapter.h"
#import "NexageDelegateProtocol.h"

@class NexageAdViewController;

@interface AdFlakeAdapterNexage : AdFlakeAdNetworkAdapter
<NexageDelegateProtocol> {
	NexageAdViewController* adViewController;
	NSString* position;
}

+ (AdFlakeAdNetworkType)networkType;
- (NSDate *)dateOfBirth;
- (NSString *)postCode;
- (NSString *)gender;
- (NSString *)keywords;
- (NSInteger)houseIncome;
- (NSString *)city;
- (NSString *)designatedMarketArea;
- (NSString *)country;
- (NSString *)ethnicity;
- (NSString *)maritalStatus;
- (NSString *)areaCode;

@end

#endif