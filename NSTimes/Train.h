//
//  Train.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Train : NSObject

@property (nonatomic, copy) NSDate *departure;
@property (nonatomic, copy) NSDate *arrival;
@property (nonatomic, copy) NSString *departureDelay;
@property (nonatomic, copy) NSString *arrivalDelay;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *travelTime;

@end
