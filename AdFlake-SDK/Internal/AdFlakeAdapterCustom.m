/**
 * AdFlakeAdapterCustom.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file AdFlakeAdapterCustom.m
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

#import "AdFlakeAdapterCustom.h"
#import "AdFlakeView.h"
#import "AdFlakeCommon.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "CJSONDeserializer.h"
#import "AdFlakeCustomAdView.h"
#import "AdFlakeAdNetworkRegistry.h"

@interface AdFlakeAdapterCustom ()

- (BOOL)parseAdData:(NSData *)data error:(NSError **)error;

@property (nonatomic,readonly) CLLocationManager *locationManager;
@property (nonatomic,retain) NSURLConnection *adConnection;
@property (nonatomic,retain) NSURLConnection *imageConnection;
@property (nonatomic,retain) AdFlakeCustomAdView *adView;
@property (nonatomic,retain) AdFlakeWebBrowserController *webBrowserController;
@property (nonatomic, assign) CGFloat scale;

@end


@implementation AdFlakeAdapterCustom

@synthesize adConnection;
@synthesize imageConnection;
@synthesize adView;
@synthesize webBrowserController;
@synthesize scale;

+ (AdFlakeAdNetworkType)networkType {
	return AdFlakeAdNetworkTypeCustom;
}

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (id)initWithAdFlakeDelegate:(id<AdFlakeDelegate>)delegate
						 view:(AdFlakeView *)view
					   config:(AdFlakeConfig *)config
				networkConfig:(AdFlakeAdNetworkConfig *)netConf {
	self = [super initWithAdFlakeDelegate:delegate
									 view:view
								   config:config
							networkConfig:netConf];
	if (self != nil) {
		adData = [[NSMutableData alloc] init];
		imageData = [[NSMutableData alloc] init];
	}
	return self;
}

- (BOOL)shouldSendExMetric {
	return NO; // since we are getting the ad from the AdFlake server anyway, no
	// need to send extra metric ping to the same server.
}

- (void)getAd {
	@synchronized(self) {
		if (requesting) return;
		requesting = YES;
	}

	NSURL *adRequestBaseURL = nil;
	if ([self.adFlakeDelegate respondsToSelector:@selector(adFlakeCustomAdURL)]) {
		adRequestBaseURL = [self.adFlakeDelegate adFlakeCustomAdURL];
	}
	if (adRequestBaseURL == nil) {
		adRequestBaseURL = [NSURL URLWithString:kAdFlakeDefaultCustomAdURL];
	}
	NSString *query;
	if (self.adFlakeConfig.locationOn) {
		AFLogDebug(@"Allow location access in custom ad");
		CLLocation *location;
		if ([self.adFlakeDelegate respondsToSelector:@selector(locationInfo)]) {
			location = [self.adFlakeDelegate locationInfo];
		}
		else {
			location = [self.locationManager location];
		}
		NSString *locationStr = [NSString stringWithFormat:@"%lf,%lf",
								 location.coordinate.latitude,
								 location.coordinate.longitude];
		query = [NSString stringWithFormat:@"?appver=%d&country_code=%@&appid=%@&nid=%@&location=%@&location_timestamp=%lf&client=1",
				 kAdFlakeAppClientVersion,
				 [[NSLocale currentLocale] localeIdentifier],
				 self.adFlakeConfig.appKey,
				 self.networkConfig.nid,
				 locationStr,
				 [[NSDate date] timeIntervalSince1970]];
	}
	else {
		AFLogDebug(@"Do not allow location access in custom ad");
		query = [NSString stringWithFormat:@"?appver=%d&country_code=%@&appid=%@&nid=%@&client=1",
				 kAdFlakeAppClientVersion,
				 [[NSLocale currentLocale] localeIdentifier],
				 self.adFlakeConfig.appKey,
				 self.networkConfig.nid];
	}
	NSURL *adRequestURL = [NSURL URLWithString:query relativeToURL:adRequestBaseURL];
	AFLogDebug(@"Requesting custom ad at %@", adRequestURL);
	NSURLRequest *adRequest = [NSURLRequest requestWithURL:adRequestURL];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:adRequest
															delegate:self];
	self.adConnection = conn;
	[conn release];
}

- (void)stopBeingDelegate {
	AdFlakeCustomAdView *theAdView = (AdFlakeCustomAdView *)self.adNetworkView;
	if (theAdView != nil) {
		theAdView.delegate = nil;
	}
}

- (void)dealloc {
	[locationManager release], locationManager = nil;
	[adConnection release], adConnection = nil;
	[adData release], adData = nil;
	[imageConnection release], imageConnection = nil;
	[imageData release], imageData = nil;
	[adView release], adView = nil;
	[webBrowserController release], webBrowserController = nil;
	[super dealloc];
}


- (CLLocationManager *)locationManager {
	if (locationManager == nil) {
		locationManager = [[CLLocationManager alloc] init];
	}
	return locationManager;
}

- (BOOL)parseEnums:(int *)val
            adInfo:(NSDictionary*)info
            minVal:(int)min
            maxVal:(int)max
         fieldName:(NSString *)name
             error:(NSError **)error {
	NSString *str = [info objectForKey:name];
	if (str == nil) {
		if (error != nil)
			*error = [AdFlakeError errorWithCode:AdFlakeCustomAdDataError
									 description:[NSString stringWithFormat:
												  @"Custom ad data has no '%@' field", name]];
		return NO;
	}
	int intVal = [str intValue];
	if (intVal <= min || intVal >= max) {
		if (error != nil)
			*error = [AdFlakeError errorWithCode:AdFlakeCustomAdDataError
									 description:[NSString stringWithFormat:
												  @"Custom ad: Invalid value for %@ - %d", name, intVal]];
		return NO;
	}
	*val = intVal;
	return YES;
}

- (BOOL)parseAdData:(NSData *)data error:(NSError **)error {
	NSError *jsonError = nil;
	id parsed = [[CJSONDeserializer deserializer] deserialize:data error:&jsonError];
	if (parsed == nil) {
		if (error != nil)
			*error = [AdFlakeError errorWithCode:AdFlakeCustomAdParseError
									 description:@"Error parsing custom ad JSON from server"
								 underlyingError:jsonError];
		return NO;
	}
	if ([parsed isKindOfClass:[NSDictionary class]]) {
		NSDictionary *adInfo = parsed;

		// gather up and validate ad info
		NSString *text = [adInfo objectForKey:@"ad_text"];
		NSString *redirectURLStr = [adInfo objectForKey:@"redirect_url"];

		int adTypeInt;
		if (![self parseEnums:&adTypeInt
					   adInfo:adInfo
					   minVal:AFCustomAdTypeMIN
					   maxVal:AFCustomAdTypeMAX
					fieldName:@"ad_type"
						error:error]) {
			return NO;
		}
		AFCustomAdType adType = adTypeInt;

		int launchTypeInt;
		if (![self parseEnums:&launchTypeInt
					   adInfo:adInfo
					   minVal:AFCustomAdLaunchTypeMIN
					   maxVal:AFCustomAdLaunchTypeMAX
					fieldName:@"launch_type"
						error:error]) {
			return NO;
		}
		AFCustomAdLaunchType launchType = launchTypeInt;

		int animTypeInt;
		if (![self parseEnums:&animTypeInt
					   adInfo:adInfo
					   minVal:AFCustomAdWebViewAnimTypeMIN
					   maxVal:AFCustomAdWebViewAnimTypeMAX
					fieldName:@"webview_animation_type"
						error:error]) {
			return NO;
		}
		AFCustomAdWebViewAnimType animType = animTypeInt;

		NSURL *redirectURL = nil;
		if (redirectURLStr == nil) {
			AFLogWarn(@"No redirect URL for custom ad");
		}
		else {
			redirectURL = [[NSURL alloc] initWithString:redirectURLStr];
			if (!redirectURL)
				AFLogWarn(@"Custom ad: Malformed redirect URL string %@", redirectURLStr);
		}

		NSString *clickMetricsURLStr = [adInfo objectForKey:@"metrics_url"];
		NSURL *clickMetricsURL = nil;
		if (clickMetricsURLStr == nil) {
			AFLogWarn(@"No click metric URL for custom ad");
		}
		else {
			clickMetricsURL = [[NSURL alloc] initWithString:clickMetricsURLStr];
			if (!clickMetricsURL)
				AFLogWarn(@"Malformed click metrics URL string %@", clickMetricsURLStr);
		}

		AFLogDebug(@"Got custom ad '%@' %@ %@ %d %d %d", text, redirectURL,
				   clickMetricsURL, adType, launchType, animType);

		AdFlakeCustomAdView *customAdView = [[AdFlakeCustomAdView alloc] initWithDelegate:self
																					 text:text
																			  redirectURL:redirectURL
																		  clickMetricsURL:clickMetricsURL
																				   adType:adType
																			   launchType:launchType
																				 animType:animType
																		  backgroundColor:[self helperBackgroundColorToUse]
																				textColor:[self helperTextColorToUse]];
		self.adView = customAdView;
		[customAdView release];
		
		self.adNetworkView = adView;
		[redirectURL release];
		[clickMetricsURL release];
		if (adView == nil) {
			if (error != nil)
				*error = [AdFlakeError errorWithCode:AdFlakeCustomAdDataError
										 description:@"Error initializing AdFlake custom ad view"];
			return NO;
		}

		// fetch image, set scale
		self.scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
		NSString *imageURL;
		if (self.scale == 2.0 && adType == AFCustomAdTypeBanner) {
			imageURL = [adInfo objectForKey:@"img_url_640x100"];
			if (imageURL == nil || [imageURL length] == 0) {
				self.scale = 1.0f;
				imageURL = [adInfo objectForKey:@"img_url"];
			}
		} else {
			imageURL = [adInfo objectForKey:@"img_url"];
			self.scale = 1.0f;
		}
		AFLogDebug(@"Request custom ad image at %@", imageURL);
		NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:imageRequest
																delegate:self];
		self.imageConnection = conn;
		[conn release];
	}
	else {
		if (error != nil)
			*error = [AdFlakeError errorWithCode:AdFlakeCustomAdDataError
									 description:@"Expected top-level dictionary in custom ad data"];
		return NO;
	}
	return YES;
}


#pragma mark NSURLConnection delegate methods.

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	if (conn == adConnection) {
		[adData setLength:0];
	}
	else if (conn == imageConnection) {
		[imageData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	if (conn == adConnection) {
		[self.adFlakeView adapter:self didFailAd:[AdFlakeError errorWithCode:AdFlakeCustomAdConnectionError
																 description:@"Error connecting to custom ad server"
															 underlyingError:error]];
		requesting = NO;
	}
	else if (conn == imageConnection) {
		[self.adFlakeView adapter:self didFailAd:[AdFlakeError errorWithCode:AdFlakeCustomAdConnectionError
																 description:@"Error connecting to custom ad server to fetch image"
															 underlyingError:error]];
		requesting = NO;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	if (conn == adConnection) {
		NSError *error = nil;
		if (![self parseAdData:adData error:&error]) {
			[self.adFlakeView adapter:self didFailAd:error];
			requesting = NO;
			return;
		}
	}
	else if (conn == imageConnection) {
		UIImage *image = [[UIImage alloc] initWithData:imageData];
		if (self.scale == 2.0) {
			UIImage *img = [[UIImage alloc] initWithCGImage:image.CGImage scale:2.0 orientation:image.imageOrientation];
			[image release];
			image = img;
		}
		if (image == nil) {
			[self.adFlakeView adapter:self didFailAd:[AdFlakeError errorWithCode:AdFlakeCustomAdImageError
																	 description:@"Cannot initialize custom ad image from data"]];
			requesting = NO;
			return;
		}
		adView.image = image;
		[adView setNeedsDisplay];
		[image release];
		requesting = NO;
		[self.adFlakeView adapter:self didReceiveAdView:self.adView];
	}
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	if (conn == adConnection) {
		[adData appendData:data];
	}
	else if (conn == imageConnection) {
		[imageData appendData:data];
	}
}


#pragma mark AdFlakeCustomAdViewDelegate methods

- (void)adTapped:(AdFlakeCustomAdView *)ad {
	if (ad != adView) return;
	if (ad.clickMetricsURL != nil) {
		NSURLRequest *metRequest = [NSURLRequest requestWithURL:ad.clickMetricsURL];
		[NSURLConnection connectionWithRequest:metRequest
									  delegate:nil]; // fire and forget
		AFLogDebug(@"Sent custom ad click ping to %@", ad.clickMetricsURL);
	}
	if (ad.redirectURL == nil) {
		AFLogError(@"Custom ad redirect URL is nil");
		return;
	}

	switch (ad.launchType) {
		case AFCustomAdLaunchTypeSafari:
			AFLogDebug(@"Opening URL '%@' for custom ad", ad.redirectURL);
			if ([[UIApplication sharedApplication] openURL:ad.redirectURL] == NO) {
				AFLogError(@"Cannot open URL '%@' for custom ad", ad.redirectURL);
			}
			break;
		case AFCustomAdLaunchTypeCanvas:
			if (self.webBrowserController == nil) {
				AdFlakeWebBrowserController *ctrlr = [[AdFlakeWebBrowserController alloc] init];
				self.webBrowserController = ctrlr;
				[ctrlr release];
			}
			webBrowserController.delegate = self;
			[webBrowserController presentWithController:[self.adFlakeDelegate viewControllerForPresentingModalView]
											 transition:ad.animType];
			[self helperNotifyDelegateOfFullScreenModal];
			[webBrowserController loadURL:ad.redirectURL];
			break;
		default:
			AFLogError(@"Custom ad: Unsupported launch type %d", ad.launchType);
			break;
	}
}


#pragma mark AdFlakeWebBrowserControllerDelegate methods

- (void)webBrowserClosed:(AdFlakeWebBrowserController *)controller {
	if (controller != webBrowserController) return;
	self.webBrowserController = nil; // don't keep around to save memory
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end

