//
//  AdFlakeAdapterMobFox.m
//  AdFlakeSDK-Sample
//
//  Created by dutty on 04.10.13.
//
//

#import "AdFlakeConfiguration.h"

#if defined(AdFlake_Enable_SDK_MobFox)
#import "AdFlakeAdapterMobFox.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeDelegateProtocol.h"
#import "AdFlakeCommon.h"
#import "AdFlakeAdNetworkRegistry.h"

@implementation AdFlakeAdapterMobFox

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType
{
	return AdFlakeAdNetworkTypeMobFox;
}

- (void)getAd
{
	MobFoxBannerView *adView = [[[MobFoxBannerView alloc] initWithFrame:kAdFlakeViewDefaultFrame] autorelease];

	adView.allowDelegateAssigmentToRequestAd = NO;
	adView.delegate = self;
	adView.requestURL = @"http://my.mobfox.com/request.php";


	self.adNetworkView = adView;

	if (adFlakeConfig.locationOn) {
	}

	if ([self helperUseTestAds])
	{
		[adView requestDemoBannerImageAdvert];
		return;
	}
    [adView requestAd]; // Request a Banner Advert
}

- (void)stopBeingDelegate
{
	if (self.adNetworkView == nil)
		return;

	((MobFoxBannerView*)self.adNetworkView).delegate = nil;
}


- (void)dealloc
{
	[super dealloc];
}

#pragma mark - MobFox delegate

- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner
{
	return self.networkConfig.pubId;
}

- (void)mobfoxBannerViewDidLoadMobFoxAd:(MobFoxBannerView *)banner
{
	[self.adFlakeView adapter:self didReceiveAdView:banner];
}

- (void)mobfoxBannerView:(MobFoxBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	[self.adFlakeView adapter:self didFailAd:error];
}


@end

#endif