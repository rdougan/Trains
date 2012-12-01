//
//  TrainsViewController.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainsViewController : UITableViewController

- (void)showRefreshControl;

#pragma mark - Trains
- (void)fetchTrains:(id)sender;

@end
