//
//  NSNLDataSource.h
//  NSTimes
//
//  Created by Simon Maddox on 06/12/2012.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Train;

@protocol NSRailConnectionDataSource <NSObject>

- (NSArray *)stations;
- (NSString *)defaultDepartureStation;
- (NSString *)defaultArrivalStation;

- (AFHTTPRequestOperation *)requestOperationWithFrom:(NSString *)from to:(NSString *)to;
- (NSString *)dateFormat;
- (BOOL)shouldDisplayTrain:(Train *)train;

- (NSArray *)trainsWithData:(NSData *)data;

@end