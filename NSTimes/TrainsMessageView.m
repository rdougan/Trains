//
//  TrainsMessageView.m
//  NSTimes
//
//  Created by Robert Dougan on 12/1/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsMessageView.h"

#import <QuartzCore/QuartzCore.h>

#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@implementation TrainsMessageView {
    UILabel *messageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x = 13.0f;
        frame.origin.y = 13.0f;
        
        // Setup the message view label
        messageView = [[OHAttributedLabel alloc] initWithFrame:frame];
        [messageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [messageView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:messageView];
    }
    return self;
}

- (void)setText:(NSString *)text detail:(NSString *)detail
{
    // Header
    NSMutableAttributedString *textString = [NSMutableAttributedString attributedStringWithString:text];
    [textString setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [textString setTextColor:[UIColor darkGrayColor]];
    
    
    // Message
    NSMutableAttributedString *detailString = [NSMutableAttributedString attributedStringWithString:detail];
    [detailString setFont:[UIFont systemFontOfSize:12.0f]];
    [detailString setTextColor:[UIColor darkGrayColor]];
    
    [textString appendAttributedString:[NSAttributedString attributedStringWithString:@"\n"]];
    [textString appendAttributedString:detailString];
    
    [messageView setAttributedText:textString];
}

@end
