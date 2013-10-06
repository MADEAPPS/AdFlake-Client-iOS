/**
 * AFNetworkReachabilityWrapper.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AFNetworkReachabilityWrapper.h
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
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <netdb.h>

@class AFNetworkReachabilityWrapper;
@protocol AFNetworkReachabilityDelegate;

// Created for ease of mocking (hence testing)
@interface AFNetworkReachabilityWrapper : NSObject {
	NSString *hostname_;
	SCNetworkReachabilityRef reachability_;
	id<AFNetworkReachabilityDelegate> delegate_;
}

@property (nonatomic,readonly) NSString *hostname;
@property (nonatomic,assign) id<AFNetworkReachabilityDelegate> delegate;

+ (AFNetworkReachabilityWrapper *) reachabilityWithHostname:(NSString *)host
										   callbackDelegate:(id<AFNetworkReachabilityDelegate>)delegate;

- (id)initWithHostname:(NSString *)host
      callbackDelegate:(id<AFNetworkReachabilityDelegate>)delegate;

- (BOOL)scheduleInCurrentRunLoop;

- (BOOL)unscheduleFromCurrentRunLoop;

@end


@protocol AFNetworkReachabilityDelegate <NSObject>

@optional
- (void)reachabilityBecameReachable:(AFNetworkReachabilityWrapper *)reachability;
- (void)reachabilityNotReachable:(AFNetworkReachabilityWrapper *)reachability;

@end
