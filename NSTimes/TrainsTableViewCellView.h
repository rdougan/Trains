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

- (id)initWithFrame:(CGRect)frame cell:(UITableViewCell *)cell;

- (void)setTrain:(Train *)train;

@end
