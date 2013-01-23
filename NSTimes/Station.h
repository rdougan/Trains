//
//  Station.h
//  NSTimes
//
//  Created by Robert Dougan on 1/23/13.
//  Copyright (c) 2013 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) CLLocation *location;

@end
