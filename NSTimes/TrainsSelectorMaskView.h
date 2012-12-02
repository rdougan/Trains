//
//  TrainsSelectorMaskView.h
//  NSTimes
//
//  Created by Robert Dougan on 12/2/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrainsSelectorMaskView;

@protocol TrainsSelectorMaskViewDelegate <NSObject>
- (void)trainsMaskViewTouchesBegan:(TrainsSelectorMaskView *)maskView;
@end

@interface TrainsSelectorMaskView : UIView

@property (nonatomic, assign) id <TrainsSelectorMaskViewDelegate> delegate;

@end
