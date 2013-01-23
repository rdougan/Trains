//
//  NSRailConnection.m
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "NSRailConnection.h"

#import "Train.h"

#import "DDXML.h"
#import "AFNetworking.h"
#import "TFHpple.h"

#import "NSNLDataSource.h"

@implementation NSRailConnection

@synthesize from = _from,
to = _to;

static NSRailConnection *sharedInstance = nil;

+ (NSRailConnection *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[NSRailConnection alloc] init];
        
        // Set the DataSource
        [sharedInstance setDataSource:[[NSNLDataSource alloc] init]];
    }
    
    return sharedInstance;
}

#pragma mark - NSUserDefaults

- (void)initUserDefaults
{
    // Grab from userdefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsTo = [userDefaults objectForKey:@"to"];
    NSString *defaultsFrom = [userDefaults objectForKey:@"from"];
    
    if (defaultsTo) {
        [self setTo:[self stationForName:defaultsTo]];
    } else {
        [self setTo:[self stationForName:[self.dataSource defaultArrivalStation]]];
    }

    if (defaultsFrom) {
        [self setFrom:[self stationForName:defaultsFrom]];
    } else {
        [self setFrom:[self stationForName:[self.dataSource defaultDepartureStation]]];
    }
}

#pragma mark - Setters

- (void)setDataSource:(id<NSRailConnectionDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self initUserDefaults];
}

- (void)setFrom:(Station *)from
{
    _from = from;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[_from name] forKey:@"from"];
}

- (void)setTo:(Station *)to
{
    _to = to;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[_to name] forKey:@"to"];
}

#pragma mark - Getters

- (NSArray *)stations
{
    return [self.dataSource stations];
}

#pragma mark - Fetching

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperation *requestOperation = [self.dataSource requestOperationWithFrom:[self.from code] to:[self.to code]];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *trains = [self.dataSource trainsWithData:responseObject];
        success(trains);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

#pragma mark - Helpers

- (Station *)stationForName:(NSString *)name
{
    NSArray *stations = [self.dataSource stations];

    int index = [stations indexOfObjectPassingTest:^BOOL(id station, NSUInteger idx, BOOL *stop) {
        NSString *stationName = [(Station *)station name];
        return ([[stationName lowercaseString] isEqualToString:[name lowercaseString]]) ? YES : NO;
    }];
    
    return [stations objectAtIndex:index];
}

- (NSDate *)dateForString:(NSString *)string
{
    NSString *dateFormat = [self.dataSource dateFormat];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (dateFormat) {
        [dateFormatter setDateFormat:dateFormat];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDate *sourceDate = [dateFormatter dateFromString:string];
    
    return sourceDate;
}

- (NSString *)normalizeString:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
