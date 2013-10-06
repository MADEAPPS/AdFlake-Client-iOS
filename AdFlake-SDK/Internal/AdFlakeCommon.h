/**
 * AdFlakeCommon.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeCommon.h
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

typedef enum {
	AFLogLevelNone  = 0,
	AFLogLevelCrit  = 10,
	AFLogLevelError = 20,
	AFLogLevelWarn  = 30,
	AFLogLevelInfo  = 40,
	AFLogLevelDebug = 50
} AFLogLevel;

void AFLogSetLogLevel(AFLogLevel level);

// The actual function name has an underscore prefix, just so we can
// hijack AFLog* with other functions for testing, by defining
// preprocessor macros
void _AFLogCrit(NSString *format, ...);
void _AFLogError(NSString *format, ...);
void _AFLogWarn(NSString *format, ...);
void _AFLogInfo(NSString *format, ...);
void _AFLogDebug(NSString *format, ...);

#ifndef AFLogCrit
#define AFLogCrit(...) _AFLogCrit(__VA_ARGS__)
#endif

#ifndef AFLogError
#define AFLogError(...) _AFLogError(__VA_ARGS__)
#endif

#ifndef AFLogWarn
#define AFLogWarn(...) _AFLogWarn(__VA_ARGS__)
#endif

#ifndef AFLogInfo
#define AFLogInfo(...) _AFLogInfo(__VA_ARGS__)
#endif

#ifndef AFLogDebug
#define AFLogDebug(...) _AFLogDebug(__VA_ARGS__)
#endif

#define AdFlakeErrorDomain @"com.adflake.sdk.ErrorDomain"

enum {
	AdFlakeConfigConnectionError = 10, /* Cannot connect to config server */
	AdFlakeConfigStatusError = 11, /* config server did not return 200 */
	AdFlakeConfigParseError = 20, /* Error parsing config from server */
	AdFlakeConfigDataError = 30,  /* Invalid config format from server */
	AdFlakeCustomAdConnectionError = 40, /* Cannot connect to custom ad server */
	AdFlakeCustomAdParseError = 50, /* Error parsing custom ad from server */
	AdFlakeCustomAdDataError = 60, /* Invalid custom ad data from server */
	AdFlakeCustomAdImageError = 70, /* Cannot create image from data */
	AdFlakeAdRequestIgnoredError = 80, /* ignoreNewAdRequests flag is set */
	AdFlakeAdRequestInProgressError = 90, /* ad request in progress */
	AdFlakeAdRequestNoConfigError = 100, /* no configurations for ad request */
	AdFlakeAdRequestTooSoonError = 110, /* requesting ad too soon */
	AdFlakeAdRequestNoMoreAdNetworks = 120, /* no more ad networks for rollover */
	AdFlakeAdRequestNoNetworkError = 130, /* no network connection */
	AdFlakeAdRequestModalActiveError = 140 /* modal view active */
};

@interface AdFlakeError : NSError {

}

+ (AdFlakeError *)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)dict;
+ (AdFlakeError *)errorWithCode:(NSInteger)code description:(NSString *)desc;
+ (AdFlakeError *)errorWithCode:(NSInteger)code description:(NSString *)desc underlyingError:(NSError *)uError;

- (id)initWithCode:(NSInteger)code userInfo:(NSDictionary *)dict;
- (id)initWithCode:(NSInteger)code description:(NSString *)desc;
- (id)initWithCode:(NSInteger)code description:(NSString *)desc underlyingError:(NSError *)uError;

@end
