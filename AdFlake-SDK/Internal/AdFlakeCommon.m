/**
 * AdFlakeCommon.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeCommon.m
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

#import "AdFlakeCommon.h"

static AFLogLevel g_AWLogLevel = AFLogLevelInfo;

void AFLogSetLogLevel(AFLogLevel level) {
	g_AWLogLevel = level;
}

void _AFLogCrit(NSString *format, ...) {
	if (g_AWLogLevel < AFLogLevelCrit) return;
	va_list ap;
	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}

void _AFLogError(NSString *format, ...) {
	if (g_AWLogLevel < AFLogLevelError) return;
	va_list ap;
	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}

void _AFLogWarn(NSString *format, ...) {
	if (g_AWLogLevel < AFLogLevelWarn) return;
	va_list ap;
	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}

void _AFLogInfo(NSString *format, ...) {
	if (g_AWLogLevel < AFLogLevelInfo) return;
	va_list ap;
	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}

void _AFLogDebug(NSString *format, ...) {
	if (g_AWLogLevel < AFLogLevelDebug) return;
	va_list ap;
	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}


@implementation AdFlakeError

+ (AdFlakeError *)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)dict {
	return [[[AdFlakeError alloc] initWithCode:code userInfo:dict] autorelease];
}

+ (AdFlakeError *)errorWithCode:(NSInteger)code description:(NSString *)desc {
	return [[[AdFlakeError alloc] initWithCode:code description:desc] autorelease];
}

+ (AdFlakeError *)errorWithCode:(NSInteger)code description:(NSString *)desc underlyingError:(NSError *)uError {
	return [[[AdFlakeError alloc] initWithCode:code description:desc underlyingError:uError] autorelease];
}

- (id)initWithCode:(NSInteger)code userInfo:(NSDictionary *)dict {
	return [super initWithDomain:AdFlakeErrorDomain code:code userInfo:dict];
}

- (id)initWithCode:(NSInteger)code description:(NSString *)desc {
	NSDictionary *eInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						   desc, NSLocalizedDescriptionKey,
						   nil];
	return [super initWithDomain:AdFlakeErrorDomain code:code userInfo:eInfo];
}

- (id)initWithCode:(NSInteger)code description:(NSString *)desc underlyingError:(NSError *)uError {
	NSDictionary *eInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						   desc, NSLocalizedDescriptionKey,
						   uError, NSUnderlyingErrorKey,
						   nil];
	return [super initWithDomain:AdFlakeErrorDomain code:code userInfo:eInfo];
}

@end

