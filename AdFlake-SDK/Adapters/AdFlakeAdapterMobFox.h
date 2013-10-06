//
//  AdFlakeAdapterMobFox.h
//  AdFlakeSDK-Sample
//
//  Created by dutty on 04.10.13.
//
//

#import "AdFlakeConfiguration.h"
#if defined(AdFlake_Enable_SDK_MobFox)

#import "AdFlakeAdNetworkAdapter.h"

#import <MobFox/MobFox.h>

@interface AdFlakeAdapterMobFox : AdFlakeAdNetworkAdapter<MobFoxBannerViewDelegate>
{
}
@end

#endif