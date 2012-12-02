//
//  TrainsSelectorMaskView.m
//  NSTimes
//
//  Created by Robert Dougan on 12/2/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsSelectorMaskView.h"

@implementation TrainsSelectorMaskView

@synthesize delegate = _delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(trainsMaskViewTouchesBegan:)]) {
        [_delegate performSelector:@selector(trainsMaskViewTouchesBegan:) withObject:self];
    }
}

@end
