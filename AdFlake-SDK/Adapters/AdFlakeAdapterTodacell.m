//
//  AdFlakeAdapterTodacell.m
//  AdFlakeSDK-Sample
//
//  Created by dutty on 04.10.13.
//
//

#import "AdFlakeConfiguration.h"

#if defined(AdFlake_Enable_SDK_Todacell)

#import "AdFlakeAdapterTodacell.h"
#import "AdFlakeView.h"
#import "AdFlakeConfig.h"
#import "AdFlakeAdNetworkConfig.h"
#import "AdFlakeAdNetworkRegistry.h"

#import "TodacellAdView.h"

@implementation AdFlakeAdapterTodacell

+ (void)load {
	[[AdFlakeAdNetworkRegistry sharedRegistry] registerClass:self];
}

+ (AdFlakeAdNetworkType)networkType
{
	return AdFlakeAdNetworkTypeTodacell;
}

- (void)getAd
{
	_view = [[UIView alloc] initWithFrame:kAdFlakeViewDefaultFrame];
	_view.clipsToBounds = false;

	mode runningMode = live;
	NSString *publisherID = self.networkConfig.pubId;

	if ([self helperUseTestAds])
	{
		publisherID = @"0";
		runningMode = test;
	}




	TodacellAdView *adView = [[[TodacellAdView alloc] initWithFrame:kAdFlakeViewDefaultFrame
														 parentView:[UIApplication sharedApplication].keyWindow
													 refreshSeconds:60
														publisherId:publisherID
														runningMode:runningMode] autorelease];
	adView.tag = 1000;
	self.adNetworkView = adView;

	[adView removeFromSuperview];
	[_view addSubview:adView];

	// NOTE: there is no delegate that we can listen to events, so we have to assume the ad is available
	[adView start];
	[self.adFlakeView adapter:self didReceiveAdView:_view];
}

- (void)stopBeingDelegate
{
	if (self.adNetworkView != nil)
	{
		TodacellAdView *adView = (TodacellAdView*)self.adNetworkView;
		[adView stop];
	}
}


- (void)dealloc
{
	if (_view != nil)
	{
		[_view removeFromSuperview];
		[_view release];
	}

	[super dealloc];
}


@end


#endif