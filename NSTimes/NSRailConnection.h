//
//  NSRailConnection.h
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Train, TFHppleElement;

@protocol NSRailConnectionDataSource <NSObject>

- (NSArray *)stations;
- (NSString *)defaultDepartureStation;
- (NSString *)defaultArrivalStation;

@optional

- (NSURLRequest *)requestWithFrom:(NSString *)from to:(NSString *)to;
- (NSURLRequest *)requestForMoreWithFrom:(NSString *)from to:(NSString *)to;

- (NSString *)XPathQueryForTrains;

- (NSDate *)train:(Train *)train departureDateFromElement:(TFHppleElement *)element;
- (NSDate *)train:(Train *)train arrivalDateFromElement:(TFHppleElement *)element;
- (NSString *)train:(Train *)train platformFromElement:(TFHppleElement *)element;
- (NSString *)train:(Train *)train travelTimeFromElement:(TFHppleElement *)element;
- (NSString *)train:(Train *)train departureDelayFromElement:(TFHppleElement *)element;
- (NSString *)train:(Train *)train arrivalDelayFromElement:(TFHppleElement *)element;
- (BOOL)shouldDisplayTrain:(Train *)train;

// Implement this if you want to provide your own parsing implementation
- (NSArray *)trainsWithData:(NSData *)data;

@end

@interface NSRailConnection : NSObject

@property (nonatomic, assign) NSString *from;
@property (nonatomic, assign) NSString *to;

@property (nonatomic, strong) id <NSRailConnectionDataSource> dataSource;

+ (NSRailConnection *)sharedInstance;

#pragma mark - Fetching

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure;
- (void)fetchMoreWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure;

#pragma mark - Normalization

- (NSDate *)dateForString:(NSString *)string;
- (NSString *)normalizeString:(NSString *)string;

#pragma mark - Stations
- (NSArray *)stations;

@end
