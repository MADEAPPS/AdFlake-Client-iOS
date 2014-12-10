/**
 * LocationController.m (AdFlakeSDK-Sample)
 *
 * Copyright © 2013 MADE GmbH - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * unless otherwise noted in the License section of this document header.
 *
 * @file LocationController.m
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

#import "LocationController.h"
#import "AdFlakeCommon.h"

#define LOCVIEW_LOCLABEL_OFFSET 79
#define LOCVIEW_LABEL_OFFSET 87
#define LOCVIEW_LABEL_HDIFF 63

@implementation LocationController

- (id)init {
	if (self = [super initWithNibName:@"LocationController" bundle:nil]) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		currLayoutOrientation = UIInterfaceOrientationPortrait; // nib file defines a portrait view
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self adjustLayoutToOrientation:self.interfaceOrientation];
}

- (UILabel *)locLabel {
	return (UILabel *)[self.view viewWithTag:103];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
										 duration:(NSTimeInterval)duration {
	[self adjustLayoutToOrientation:interfaceOrientation];
}

- (void)adjustLayoutToOrientation:(UIInterfaceOrientation)newOrientation {
	UILabel *ll = self.locLabel;
	UILabel *label = self.label;
	assert(ll != nil);
	assert(label != nil);
	if (UIInterfaceOrientationIsPortrait(currLayoutOrientation)
		&& UIInterfaceOrientationIsLandscape(newOrientation)) {
		CGPoint newCenter = ll.center;
		newCenter.y -= LOCVIEW_LOCLABEL_OFFSET;
		ll.center = newCenter;
		CGRect newFrame = label.frame;
		newFrame.origin.y -= LOCVIEW_LABEL_OFFSET;
		newFrame.size.height -= LOCVIEW_LABEL_HDIFF;
		label.frame = newFrame;
	}
	else if (UIInterfaceOrientationIsLandscape(currLayoutOrientation)
			 && UIInterfaceOrientationIsPortrait(newOrientation)) {
		CGPoint newCenter = ll.center;
		newCenter.y += LOCVIEW_LOCLABEL_OFFSET;
		ll.center = newCenter;
		CGRect newFrame = label.frame;
		newFrame.origin.y += LOCVIEW_LABEL_OFFSET;
		newFrame.size.height += LOCVIEW_LABEL_HDIFF;
		label.frame = newFrame;
	}
	currLayoutOrientation = newOrientation;
}

- (void)dealloc {
	locationManager.delegate = nil;
	[locationManager release], locationManager = nil;
	[super dealloc];
}


#pragma mark AdFlakeDelegate methods

- (CLLocation *)locationInfo {
	CLLocation *loc = [locationManager location];
	AFLogDebug(@"AdFlake asking for location: %@", loc);
	return loc;
}


#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	[locationManager stopUpdatingLocation];
	self.locLabel.text = [NSString stringWithFormat:@"Error getting location: %@",
						  [error localizedDescription]];
	AFLogError(@"Failed getting location: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	self.locLabel.text = [NSString stringWithFormat:@"%lf %lf",
						  newLocation.coordinate.longitude,
						  newLocation.coordinate.latitude];
}

@end
