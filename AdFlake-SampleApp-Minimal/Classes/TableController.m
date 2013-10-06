/**
 * TableController.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file TableController.m
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

#import "AdFlakeSDK-SampleAppDelegate.h"
#import "TableController.h"
#import "AdFlakeView.h"
#import "SampleConstants.h"


@implementation TableController

@synthesize adView;

- (id)init {
  if (self = [super initWithNibName:@"TableController" bundle:nil]) {
    self.title = @"Ad In Table";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.adView = [AdFlakeView requestAdFlakeViewWithDelegate:self];
  self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self.adView rotateToOrientation:toInterfaceOrientation];
  [self adjustAdSize];
}

- (UILabel *)label {
  return (UILabel *)[self.view viewWithTag:1337];
}

- (UITableView *)table {
  return (UITableView *)[self.view viewWithTag:3337];
}

- (void)adjustAdSize {
  [UIView beginAnimations:@"AdResize" context:nil];
  [UIView setAnimationDuration:0.7];
  CGSize adSize = [adView actualAdSize];
  CGRect newFrame = adView.frame;
  newFrame.size.height = adSize.height;
  newFrame.size.width = adSize.width;
  newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
  adView.frame = newFrame;
  [UIView commitAnimations];
}

- (void)dealloc {
  self.adView.delegate = nil;
  self.adView = nil;
  [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";
  static NSString *AdCellIdentifier = @"AdCell";

  NSString *cellId = CellIdentifier;
  if (indexPath.row == 0) {
    cellId = AdCellIdentifier;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    if ([UITableViewCell instancesRespondToSelector:@selector(initWithStyle:reuseIdentifier:)]) {
      // iPhone SDK 3.0
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    else {
      // iPhone SDK 2.2.1
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
    }
    if (cellId == AdCellIdentifier) {
      [cell.contentView addSubview:adView];
    }
  }

  switch (indexPath.row) {
    case 0:
      break;
    case 1:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Request New Ad";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Request New Ad";
      }
      break;
    case 2:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Roll Over";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Roll Over";
      }
      break;
    default:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
      }
  }

  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case 1:
      self.label.text = @"Request New Ad pressed! Requesting...";
      [adView requestFreshAd];
      break;
    case 2:
      self.label.text = @"Roll Over pressed! Requesting...";
      [adView rollOver];
      break;
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) {
    return CGRectGetHeight(adView.bounds);
  }
  return self.table.rowHeight;
}


#pragma mark AdFlakeDelegate methods

- (NSString *)adFlakeApplicationKey {
  return kSampleAppKey;
}

- (UIViewController *)viewControllerForPresentingModalView {
  return [((AdFlakeSDKSampleAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
}

- (NSURL *)adFlakeConfigURL {
  return [NSURL URLWithString:kSampleConfigURL];
}

- (NSURL *)adFlakeImpMetricURL {
  return [NSURL URLWithString:kSampleImpMetricURL];
}

- (NSURL *)adFlakeClickMetricURL {
  return [NSURL URLWithString:kSampleClickMetricURL];
}

- (NSURL *)adFlakeCustomAdURL {
  return [NSURL URLWithString:kSampleCustomAdURL];
}

- (void)adFlakeDidReceiveAd:(AdFlakeView *)adFlakeView {
  self.label.text = [NSString stringWithFormat:
                     @"Got ad from %@, size %@",
                     [adFlakeView mostRecentNetworkName],
                     NSStringFromCGSize([adFlakeView actualAdSize])];
  [self adjustAdSize];
}

- (void)adFlakeDidFailToReceiveAd:(AdFlakeView *)adFlakeView usingBackup:(BOOL)yesOrNo {
  self.label.text = [NSString stringWithFormat:
                     @"Failed to receive ad from %@, %@. Error: %@",
                     [adFlakeView mostRecentNetworkName],
                     yesOrNo? @"will use backup" : @"will NOT use backup",
                     adFlakeView.lastError == nil? @"no error" : [adFlakeView.lastError localizedDescription]];
}

- (void)adFlakeReceivedRequestForDeveloperToFufill:(AdFlakeView *)adFlakeView {
  UILabel *replacement = [[UILabel alloc] initWithFrame:kAdFlakeViewDefaultFrame];
  replacement.backgroundColor = [UIColor redColor];
  replacement.textColor = [UIColor whiteColor];
  replacement.textAlignment = UITextAlignmentCenter;
  replacement.text = @"Generic Notification";
  [adFlakeView replaceBannerViewWith:replacement];
  [replacement release];
  [self adjustAdSize];
  self.label.text = @"Generic Notification";
}

- (void)adFlakeDidAnimateToNewAdIn:(AdFlakeView *)adFlakeView {
  [self.table reloadData];
}

- (void)adFlakeReceivedNotificationAdsAreOff:(AdFlakeView *)adFlakeView {
  self.label.text = @"Ads are off";
}

- (void)adFlakeWillPresentFullScreenModal {
  NSLog(@"TableView: will present full screen modal");
}

- (void)adFlakeDidDismissFullScreenModal {
  NSLog(@"TableView: did dismiss full screen modal");
}

- (void)adFlakeDidReceiveConfig:(AdFlakeView *)adFlakeView {
  self.label.text = @"Received config. Requesting ad...";
}

- (BOOL)adFlakeTestMode {
  return YES;
}

- (NSUInteger)jumptapTransitionType {
  return 3;
}


#pragma mark event methods

- (void)performEvent {
  self.label.text = @"Event performed";
}

- (void)performEvent2:(AdFlakeView *)adFlakeView {
  UILabel *replacement = [[UILabel alloc] initWithFrame:kAdFlakeViewDefaultFrame];
  replacement.backgroundColor = [UIColor blackColor];
  replacement.textColor = [UIColor whiteColor];
  replacement.textAlignment = UITextAlignmentCenter;
  replacement.text = [NSString stringWithFormat:@"Event performed, view %@", adFlakeView];
  [adFlakeView replaceBannerViewWith:replacement];
  [replacement release];
  [self adjustAdSize];
  self.label.text = [NSString stringWithFormat:@"Event performed, view %@", adFlakeView];
}

@end

