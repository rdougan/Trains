//
//  NSRailConnection.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRailConnection : NSObject

@property (nonatomic, assign) NSString *from;
@property (nonatomic, assign) NSString *to;

+ (NSRailConnection *)sharedInstance;

- (NSURLRequest *)requestWithFrom:(NSString *)from to:(NSString *)to;

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success;

- (NSArray *)trainsWithElements:(NSArray *)elements;

- (NSDate *)dateForString:(NSString *)string;
- (NSString *)normalizeString:(NSString *)string;

@end
