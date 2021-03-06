/**
 * SimpleViewController.h (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file SimpleViewController.h
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

#import <UIKit/UIKit.h>
#import "AdFlakeDelegateProtocol.h"

@class AdFlakeView;
@interface SimpleViewController : UIViewController <AdFlakeDelegate> {
  AdFlakeView *adView;
  UIInterfaceOrientation currLayoutOrientation;
}

- (IBAction)requestNewAd:(id)sender;
- (IBAction)requestNewConfig:(id)sender;
- (IBAction)rollOver:(id)sender;
- (IBAction)showModalView:(id)sender;
- (IBAction)toggleRefreshAd:(id)sender;
- (IBAction)presentVideoAd:(id)sender;
- (void)adjustAdSize;

@property (nonatomic,retain) AdFlakeView *adView;
@property (nonatomic,readonly) UILabel *label;
@property (nonatomic, assign) IBOutlet UILabel *videoStatusLabel;

@end
