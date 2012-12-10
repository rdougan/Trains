//
//  NSNLDataSource.h
//  NSTimes
//
//  Created by Simon Maddox on 06/12/2012.
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