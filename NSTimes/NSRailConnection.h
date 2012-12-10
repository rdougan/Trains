//
//  NSRailConnection.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSRailConnectionDataSource.h"

@interface NSRailConnection : NSObject

@property (nonatomic, assign) NSString *from;
@property (nonatomic, assign) NSString *to;

@property (nonatomic, strong) id <NSRailConnectionDataSource> dataSource;

+ (NSRailConnection *)sharedInstance;

#pragma mark - Fetching

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure;

#pragma mark - Normalization

- (NSDate *)dateForString:(NSString *)string;
- (NSString *)normalizeString:(NSString *)string;

#pragma mark - Stations
- (NSArray *)stations;

@end
