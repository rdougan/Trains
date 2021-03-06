//
//  TrainsTableViewCellView.m
//  NSTimes
//
//  Created by Robert Dougan on 11/30/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsTableViewCellView.h"

#import "Train.h"

#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

#define CellPadding 10.0f

@interface TrainsTableViewCellView ()

@property (nonatomic, retain) UILabel *minutesLabel;
@property (nonatomic, retain) UILabel *departureLabel;
@property (nonatomic, retain) UILabel *departureDelayLabel;
@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) UILabel *platformLabel;

@end

@implementation TrainsTableViewCellView

@synthesize cell = _cell;

@synthesize minutesLabel = _minutesLabel,
departureLabel = _departureLabel,
departureDelayLabel = _departureDelayLabel,
durationLabel = _durationLabel,
platformLabel = _platformLabel;

- (id)initWithFrame:(CGRect)frame cell:(UITableViewCell *)cell
{
    self = [super initWithFrame:frame];
    if (self) {
        _cell = cell;
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _minutesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_minutesLabel setFont:[UIFont boldSystemFontOfSize:40.0f]];
        [_minutesLabel setTextColor:[UIColor blackColor]];
        [_minutesLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_minutesLabel];
        
        _departureDelayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_departureDelayLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_departureDelayLabel setTextColor:[UIColor redColor]];
        [_departureDelayLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self addSubview:_departureDelayLabel];
        
        _departureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_departureLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_departureLabel setTextColor:[UIColor lightGrayColor]];
        [_departureLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_departureLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_departureLabel];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_durationLabel setTextColor:[UIColor colorWithRed:0.482 green:0.569 blue:0.686 alpha:0.5f]];
        [_durationLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_durationLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_durationLabel];
        
        _platformLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        [_platformLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_platformLabel setTextColor:[UIColor darkGrayColor]];
        [_platformLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_platformLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [_minutesLabel sizeToFit];
    [_departureDelayLabel sizeToFit];
    [_departureLabel sizeToFit];
    [_durationLabel sizeToFit];
    [_platformLabel sizeToFit];
    
    CGRect minutesLabelFrame = _minutesLabel.frame;
    minutesLabelFrame.origin.x = CellPadding;
    minutesLabelFrame.origin.y = CellPadding;
    minutesLabelFrame.size.height = self.bounds.size.height - (CellPadding * 2);
    minutesLabelFrame.size.width = self.bounds.size.width - (CellPadding * 2);
    
    float firstRowOffset = 14.0f;
    if ([[_durationLabel text] isEqualToString:@""] && [[_platformLabel text] isEqualToString:@""]) {
        firstRowOffset = 23.0f;
    }
    
    CGRect departureDelayLabelFrame = _departureDelayLabel.frame;
    departureDelayLabelFrame.origin.x = self.bounds.size.width - CellPadding - departureDelayLabelFrame.size.width;
    departureDelayLabelFrame.origin.y = firstRowOffset;
    
    CGRect departureLabelFrame = _departureLabel.frame;
    departureLabelFrame.origin.x = self.bounds.size.width - 8.0f - departureDelayLabelFrame.size.width - departureLabelFrame.size.width;
    departureLabelFrame.origin.y = firstRowOffset;

    CGRect platformLabelFrame = _platformLabel.frame;
    platformLabelFrame.origin.x = self.bounds.size.width - CellPadding - platformLabelFrame.size.width;
    platformLabelFrame.origin.y = departureLabelFrame.origin.y + departureLabelFrame.size.height - 1.0f;
    
    CGRect durationLabelFrame = _durationLabel.frame;
    if ([[_platformLabel text] isEqualToString:@""]) {
        durationLabelFrame.origin.x = self.bounds.size.width - CellPadding - durationLabelFrame.size.width + 1.0f;
    } else {
        durationLabelFrame.origin.x = platformLabelFrame.origin.x - durationLabelFrame.size.width - 2.0f;
    }
    durationLabelFrame.origin.y = platformLabelFrame.origin.y + 0.5f;
    
    _minutesLabel.frame = minutesLabelFrame;
    _departureDelayLabel.frame = departureDelayLabelFrame;
    _departureLabel.frame = departureLabelFrame;
    _durationLabel.frame = durationLabelFrame;
    _platformLabel.frame = platformLabelFrame;
}

- (void)setTrain:(Train *)train
{
    // Minutes
    NSDate *now = [NSDate date];
    NSTimeInterval diff = [[train departure] timeIntervalSinceDate:now];
    
    [_minutesLabel setText:[NSString stringWithFormat:@"%im", [[NSNumber numberWithFloat:diff / 60.0f] intValue]]];
    
    // Depature Delay
    if ([train departureDelay]) {
        [_departureDelayLabel setText:[NSString stringWithFormat:@" %@", [train departureDelay]]];
    } else {
        [_departureDelayLabel setText:@""];
    }
    
    // Departure
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    [_departureLabel setText:[dateFormatter stringFromDate:[train departure]]];
    
    // Duration
    if ([train travelTime] && ![[train travelTime] isEqualToString:@""]) {
        [_durationLabel setText:[NSString stringWithFormat:@"%@m", [train travelTime]]];
    } else {
        [_durationLabel setText:@""];
    }
    
    // Platform
    if ([train platform] && ![[train platform] isEqualToString:@""]) {
        NSMutableAttributedString *platformText = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"platform", @"Platform"), [train platform]]];
        [platformText setFont:[UIFont boldSystemFontOfSize:13.0f] range:[[platformText string] rangeOfString:[train platform]]];
        [platformText setTextAlignment:kCTRightTextAlignment lineBreakMode:NSLineBreakByClipping];
        [_platformLabel setAttributedText:platformText];
    } else {
        [_platformLabel setText:@""];
    }
    
    [self layoutSubviews];
}

@end
