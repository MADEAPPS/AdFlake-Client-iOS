/**
 * RootViewController.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file RootViewController.h
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
#import "RootViewController.h"
#import "SimpleViewController.h"
#import "TableController.h"
#import "BottomBannerController.h"
#import "LocationController.h"
#import "AdFlakeView.h"
#import "SampleConstants.h"

#define CONFIG_PREFETCH_ROW 4

@implementation RootViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CONFIG_PREFETCH_ROW+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    if ([UITableViewCell instancesRespondToSelector:@selector(initWithStyle:reuseIdentifier:)]) {
      // iPhone SDK 3.0
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else {
      // iPhone SDK 2.2.1
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
  }

  switch (indexPath.row) {
    case 0:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Simple View";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Simple View";
      }
      break;
    case 1:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Table Integration";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Table Integration";
      }
      break;
    case 2:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Bottom Banner";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Bottom Banner";
      }
      break;
    case 3:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Table w/ Location Info";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Table w/ Location Info";
      }
      break;
    case CONFIG_PREFETCH_ROW:
    {
      NSString *configText;
      if (configFetched) {
        configText = @"Update Config";
      }
      else {
        configText = @"Prefetch Config";
      }
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = configText;
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = configText;
      }
      break;
    }
  }

  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case 0:
    {
      SimpleViewController *simple = [[SimpleViewController alloc] init];
      [self.navigationController pushViewController:simple animated:YES];
      [simple release];
      break;
    }
    case 1:
    {
      TableController *table = [[TableController alloc] init];
      [self.navigationController pushViewController:table animated:YES];
      [table release];
      break;
    }
    case 2:
    {
      BottomBannerController *bbc = [[BottomBannerController alloc] init];
      [self.navigationController pushViewController:bbc animated:YES];
      [bbc release];
      break;
    }
    case 3:
    {
      LocationController *loc = [[LocationController alloc] init];
      [self.navigationController pushViewController:loc animated:YES];
      [loc release];
      break;
    }
    case CONFIG_PREFETCH_ROW:
      if (configFetched) {
        [AdFlakeView updateAdFlakeConfigWithDelegate:self];
      }
      else {
        [AdFlakeView startPreFetchingConfigurationDataWithDelegate:self];
      }
      break;
  }
}


- (void)dealloc {
    [super dealloc];
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

- (void)adFlakeDidReceiveConfig:(AdFlakeView *)adFlakeView {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CONFIG_PREFETCH_ROW inSection:0];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  configFetched = YES;
  [self.tableView reloadData];
}

@end

