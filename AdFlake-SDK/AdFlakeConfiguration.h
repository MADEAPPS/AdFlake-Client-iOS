/**
 * AdFlakeConfiguration.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeConfiguration.h
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

#ifndef AdFlakeSDK_AdFlakeConfiguration_h
#define AdFlakeSDK_AdFlakeConfiguration_h

/**
 * This is file configures the build settings for the AdFlake iOS SDK.
 * It enables you to deactivate adapters which are then not included in your
 * final executable.
 * Simply remove the comments before the defines of the ad network you want
 * to include.
 * 
 * If an adapter is enable, it is required that the client SDK of the
 * adapter is dragged into your project.
 * The client SDKs are always available on the website of the ad network.
 * It is possible that a client SDK requires additional project configuration
 * for example the inclusion of additional system frameworks or libraries.
 */


#warning Remove comments from AdNetworks you want to utilize

#define AdFlake_Enable_SDK_AppleIAD		/**< iADs are always available by default. Since no additional dependency. */
//#define AdFlake_Enable_SDK_BeachfrontIO
//#define AdFlake_Enable_SDK_GoogleAdMob
//#define AdFlake_Enable_SDK_AdColony
//#define AdFlake_Enable_SDK_MdotM
//#define AdFlake_Enable_SDK_MillennialMedia
//#define AdFlake_Enable_SDK_MobClix
//#define AdFlake_Enable_SDK_GreyStripe
//#define AdFlake_Enable_SDK_InMobi
//#define AdFlake_Enable_SDK_JumpTap
//#define AdFlake_Enable_SDK_LeadBolt
//#define AdFlake_Enable_SDK_Todacell
//#define AdFlake_Enable_SDK_MobFox
//#define AdFlake_Enable_SDK_KomliMobile /**< Formerly known as ZestADZ. WARNING: Enabling both KomliMobile and MobFox may lead to linker errors */


/**
 * NOTE: these AD networks are currently not supported on iOS
 * due to the fact that we don't have a SDK available. If you have an
 * SDK for any of the networks available. Please contact us and we will
 * implement the adapters.
 */
//#define AdFlake_Enable_SDK_BrightRoll
//#define AdFlake_Enable_SDK_SayMedia /**< Formerly known as VideoEgg. */
//#define AdFlake_Enable_SDK_Nexage

#endif
