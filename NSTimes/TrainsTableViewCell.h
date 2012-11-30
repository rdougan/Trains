//
//  TrainsTableViewCell.h
//  NSTimes
//
//  Created by Robert Dougan on 11/30/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrainsTableViewCellView;
@class Train;

@interface TrainsTableViewCell : UITableViewCell

@property (nonatomic, retain) TrainsTableViewCellView *customView;

- (void)setTrain:(Train *)train;

@end
