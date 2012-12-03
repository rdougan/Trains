//
//  TrainsViewController.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TrainsSelectorView.h"
#import "LocationManager.h"

@interface TrainsViewController : UITableViewController <TrainsSelectorViewDelegate, LocationManagerDelegate>

- (void)showRefreshControl;

#pragma mark - Trains
- (void)switchStationsIfNeeded;
- (void)fetchTrains:(id)sender;

@end
