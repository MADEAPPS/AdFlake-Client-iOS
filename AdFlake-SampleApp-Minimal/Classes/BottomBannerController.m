/**
 * BottomBannerController.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file BottomBannerController.m
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

#import "BottomBannerController.h"
#import "AdFlakeView.h"

#define BOTBVIEW_BUTTON_1_TAG 607701
#define BOTBVIEW_BUTTON_2_TAG 607702
#define BOTBVIEW_BUTTON_1_OFFSET 15
#define BOTBVIEW_BUTTON_2_OFFSET 37
#define BOTBVIEW_LABEL_OFFSET 67
#define BOTBVIEW_LABEL_HDIFF 45

@implementation BottomBannerController

- (id)init {
  if (self = [super initWithNibName:@"BottomBannerController" bundle:nil]) {
    currLayoutOrientation = UIInterfaceOrientationPortrait; // nib file defines a portrait view
    self.title = @"Bottom Banner";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [self adjustLayoutToOrientation:interfaceOrientation];
}

- (void)adjustLayoutToOrientation:(UIInterfaceOrientation)newOrientation {
  if (UIInterfaceOrientationIsPortrait(currLayoutOrientation)
      && UIInterfaceOrientationIsLandscape(newOrientation)) {
    UIView *button1 = [self.view viewWithTag:BOTBVIEW_BUTTON_1_TAG];
    UIView *button2 = [self.view viewWithTag:BOTBVIEW_BUTTON_2_TAG];
    assert(button1 != nil);
    assert(button2 != nil);
    CGPoint newCenter = button1.center;
    newCenter.y -= BOTBVIEW_BUTTON_1_OFFSET;
    button1.center = newCenter;
    newCenter = button2.center;
    newCenter.y -= BOTBVIEW_BUTTON_2_OFFSET;
    button2.center = newCenter;
    CGRect newFrame = self.label.frame;
    newFrame.size.height -= 45;
    newFrame.origin.y -= BOTBVIEW_LABEL_OFFSET;
    self.label.frame = newFrame;
  }
  else if (UIInterfaceOrientationIsLandscape(currLayoutOrientation)
           && UIInterfaceOrientationIsPortrait(newOrientation)) {
    UIView *button1 = [self.view viewWithTag:BOTBVIEW_BUTTON_1_TAG];
    UIView *button2 = [self.view viewWithTag:BOTBVIEW_BUTTON_2_TAG];
    assert(button1 != nil);
    assert(button2 != nil);
    CGPoint newCenter = button1.center;
    newCenter.y += BOTBVIEW_BUTTON_1_OFFSET;
    button1.center = newCenter;
    newCenter = button2.center;
    newCenter.y += BOTBVIEW_BUTTON_2_OFFSET;
    button2.center = newCenter;
    CGRect newFrame = self.label.frame;
    newFrame.size.height += 45;
    newFrame.origin.y += BOTBVIEW_LABEL_OFFSET;
    self.label.frame = newFrame;
  }
  CGRect adFrame = [adView frame];
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  if (UIInterfaceOrientationIsPortrait(newOrientation)) {
    adFrame.origin.y = screenBounds.size.height
      - adFrame.size.height
      - self.navigationController.navigationBar.frame.size.height
      - [UIApplication sharedApplication].statusBarFrame.size.height;
    [adView setFrame:adFrame];
  }
  else if (UIInterfaceOrientationIsLandscape(newOrientation)) {
    adFrame.origin.y = screenBounds.size.width
      - adFrame.size.height
      - self.navigationController.navigationBar.frame.size.height
      - [UIApplication sharedApplication].statusBarFrame.size.width;
    [adView setFrame:adFrame];
  }
  currLayoutOrientation = newOrientation;
}

- (void)adjustAdSize {
  [UIView beginAnimations:@"AdResize" context:nil];
  [UIView setAnimationDuration:0.7];
  CGSize adSize = [adView actualAdSize];
  CGRect newFrame = adView.frame;
  newFrame.size.height = adSize.height;
  newFrame.size.width = adSize.width;
  newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
  newFrame.origin.y = self.view.bounds.size.height - adSize.height;
  adView.frame = newFrame;
  [UIView commitAnimations];
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark AdFlakeDelegate methods

- (NSUInteger)millennialMediaAdType {
  return 2;
}

@end

