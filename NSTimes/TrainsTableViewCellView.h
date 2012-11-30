//
//  TrainsTableViewCellView.h
//  NSTimes
//
//  Created by Robert Dougan on 11/30/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Train;

@interface TrainsTableViewCellView : UIView

@property (nonatomic, retain) UITableViewCell *cell;

@property (nonatomic, retain) UILabel *minutesLabel;
@property (nonatomic, retain) UILabel *departureLabel;
@property (nonatomic, retain) UILabel *departureDelayLabel;
@property (nonatomic, retain) UILabel *platformLabel;

- (id)initWithFrame:(CGRect)frame cell:(UITableViewCell *)cell;

- (void)setTrain:(Train *)train;

@end
