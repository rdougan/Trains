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

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // UserDefaults
        [self initUserDefaults];
    }
    return self;
}

#pragma mark - NSUserDefaults

- (void)initUserDefaults
{
    // Grab from userdefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsTo = [userDefaults objectForKey:@"to"];
    NSString *defaultsFrom = [userDefaults objectForKey:@"from"];
    
    if (defaultsTo) {
        [self setTo:defaultsTo];
    } else {
        [self setTo:[self.dataSource defaultArrivalStation]];
    }
    
    if (defaultsFrom) {
        [self setFrom:defaultsFrom];
    } else {
        [self setFrom:[self.dataSource defaultDepartureStation]];
    }
}

#pragma mark - Setters

- (void)setFrom:(NSString *)from
{
    _from = from;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_from forKey:@"from"];
}

- (void)setTo:(NSString *)to
{
    _to = to;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_to forKey:@"to"];
}

#pragma mark - Getters

- (NSArray *)stations
{
    return [self.dataSource stations];
}

#pragma mark - Fetching

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *urlRequest = [self.dataSource requestWithFrom:self.from to:self.to];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [document searchWithXPathQuery:[self.dataSource XPathQueryForTrains]];
        
        success([self trainsWithHTMLElements:elements]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

- (void)fetchMoreWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *urlRequest = [self.dataSource requestForMoreWithFrom:self.from to:self.to];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success([self trainsWithXMLData:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

#pragma mark - Element searching

- (NSArray *)trainsWithHTMLElements:(NSArray *)elements {
    NSMutableArray *trains = [NSMutableArray array];
    BOOL foundSelected = NO;
    
    for (TFHppleElement *element in elements) {
        Train *train = [[Train alloc] init];
        
        // Check if something has been selected
        if (!foundSelected) {
            if ([[element objectForKey:@"class"] isEqualToString:@"selected"]) {
                foundSelected = YES;
            } else {
                continue;
            }
        }
        
        // Simple fields
        [train setPlatform:[self.dataSource train:train platformFromElement:element]];
        [train setTravelTime:[self.dataSource train:train travelTimeFromElement:element]];
        
        // Delays
        [train setDepartureDelay:[self.dataSource train:train departureDelayFromElement:element]];
        [train setArrivalDelay:[self.dataSource train:train arrivalDelayFromElement:element]];
        
        // Times
        [train setDeparture:[self.dataSource train:train departureDateFromElement:element]];
        [train setArrival:[self.dataSource train:train arrivalDateFromElement:element]];
        
        if ([self.dataSource shouldDisplayTrain:train]) {
            [trains addObject:train];
        }
    }
    
    return trains;
}

- (NSArray *)trainsWithXMLData:(NSData *)data {
    return [self.dataSource trainsWithData:data];
}

#pragma mark - Helpers

- (NSDate *)dateForString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDate *sourceDate = [dateFormatter dateFromString:string];
    
    return sourceDate;
}

- (NSString *)normalizeString:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
