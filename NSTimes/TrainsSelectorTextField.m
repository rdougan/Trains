//
//  TrainsSelectorTextField.m
//  NSTimes
//
//  Created by Robert Dougan on 12/2/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsSelectorTextField.h"

@implementation TrainsSelectorTextField {
    UILabel *label;
    UIImageView *backgroundView;
}

- (id)initWithFrame:(CGRect)frame withLabel:(NSString *)_label
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:[UIFont systemFontOfSize:15.0f]];
        [self setBorderStyle:UITextBorderStyleNone];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self setTextEdgeInsets:UIEdgeInsetsMake(3.0f, 50.0f, 0, 0)];
        
        backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"selector_textfield_bg"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f]];
        [backgroundView setFrame:self.bounds];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self addSubview:backgroundView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45.0f, self.bounds.size.height - 1)];
        [label setText:_label];
        [label setTextAlignment:NSTextAlignmentRight];
        [label setFont:[UIFont systemFontOfSize:15.0f]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor lightGrayColor]];
        [self addSubview:label];
    }
    return self;
}

@end
