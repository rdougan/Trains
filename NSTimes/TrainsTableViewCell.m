//
//  TrainsTableViewCell.m
//  NSTimes
//
//  Created by Robert Dougan on 11/30/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsTableViewCell.h"

#import "Train.h"

#import "TrainsTableViewCellView.h"

@implementation TrainsTableViewCell

@synthesize customView = _customView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect viewFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        
        // Create the custom view
        _customView = [[TrainsTableViewCellView alloc] initWithFrame:viewFrame cell:self];
        [_customView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        [self.contentView addSubview:_customView];
    }
    return self;
}

- (void)setTrain:(Train *)train
{
    [_customView setTrain:train];
}

@end
