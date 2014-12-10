/**
 * SampleConstants.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file SampleConstants.h
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

#if !defined(kSampleAppKey)
#	error "You must define kSampleAppKey as your AdFlake SDK Key"
//#	define kSampleAppKey	@"54887f0ea7cfb3bf8cd54418"
#endif

#define kSampleConfigURL		@"http://api.adflake.com/get"
#define kSampleImpMetricURL		@"http://metrics.adflake.com/impression"
#define kSampleClickMetricURL	@"http://metrics.adflake.com/click"
#define kSampleCustomAdURL		@"http://api.adflake.com/custom"
