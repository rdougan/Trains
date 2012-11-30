//
//  Train.m
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "Train.h"

@implementation Train

@synthesize departure, arrival, departureDelay, arrivalDelay, platform, travelTime;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Train: (travelTime: %@, platform: %@, departure: %@, arrival: %@, departureDelay: %@, arrivalDelay: %@)", self.travelTime, self.platform, self.departure, self.arrival, self.departureDelay, self.arrivalDelay];
}

@end
