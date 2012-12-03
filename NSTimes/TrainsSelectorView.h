//
//  TrainsSelectorView.h
//  NSTimes
//
//  Created by Robert Dougan on 12/1/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "TrainsSelectorMaskView.h"

@class TrainsSelectorView;

typedef enum {
    TrainsSelectorViewStateValid = 0,
    TrainsSelectorViewStateInvalid = 1
} TrainsSelectorViewState;

@protocol TrainsSelectorViewDelegate <NSObject>
- (void)trainsSelectorView:(TrainsSelectorView *)trainsSelectorView didCompleteSearchWithFrom:(NSString *)from to:(NSString *)to;
- (void)trainsSelectorViewDidCancel:(TrainsSelectorView *)trainsSelectorView;
@end

@interface TrainsSelectorView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, TrainsSelectorMaskViewDelegate>

@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;

@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, assign) id <TrainsSelectorViewDelegate> delegate;

- (void)submit;
- (void)cancel;
- (void)setStateChangeBlock:(void (^)(TrainsSelectorViewState state))block;

@end


