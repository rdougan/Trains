//
//  NSNLDataSource.m
//  NSTimes
//
//  Created by Simon Maddox on 06/12/2012.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "NSNLDataSource.h"
#import "DDXML.h"

@implementation NSNLDataSource {
    NSArray *cachedStations;
}

- (AFHTTPRequestOperation *)requestOperationWithFrom:(NSString *)from to:(NSString *)to
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:self.dateFormat];
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    date = [date stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    date = [date stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSString *URL = [NSString stringWithFormat:@"http://ews-rpx.ns.nl/mobile-api-planner?yearCard=false&dateTime=%@&nextAdvices=5&hslAllowed=true&toStation=%@&departure=true&fromStation=%@", date, from, to];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"iOS2011" password:@"iOS2001" persistence:NSURLCredentialPersistenceForSession];
        [challenge.sender useCredential:newCredential forAuthenticationChallenge:challenge];
    }];
    
    return operation;
}

- (NSString *)dateFormat
{
    return @"yyyy-MM-dd'T'HH:mm:ssZZZ"; //2013-01-23T22:03:00+0100
}

- (BOOL)shouldDisplayTrain:(Train *)train
{
    NSInteger diff = ([train.departure timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate]) / 60;
    
    return (diff <= 101);
}

- (NSArray *)trainsWithData:(NSData *)data
{
    NSMutableArray *trains = [NSMutableArray array];
    
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *elements = [document nodesForXPath:@"//ReisMogelijkheden/ReisMogelijkheid" error:nil];
    
    for (DDXMLElement *element in elements) {
        Train *train = [[Train alloc] init];
        
        // Simple fields
        [train setPlatform:[[NSRailConnection sharedInstance] normalizeString:[[[element nodesForXPath:@"ReisDeel/ReisStop[1]/Spoor" error:nil] objectAtIndex:0] stringValue]]];
        [train setTravelTime:[[NSRailConnection sharedInstance] normalizeString:[[[[element nodesForXPath:@"GeplandeReisTijd" error:nil] objectAtIndex:0] stringValue] stringByReplacingOccurrencesOfString:@"0:" withString:@""]]];

        // Depature
        NSDate *scheduledDeparture = [[NSRailConnection sharedInstance] dateForString:[[[element nodesForXPath:@"GeplandeVertrekTijd" error:nil] objectAtIndex:0] stringValue]];
        NSDate *expectedDeparture = [[NSRailConnection sharedInstance] dateForString:[[[element nodesForXPath:@"ActueleVertrekTijd" error:nil] objectAtIndex:0] stringValue]];
        
        NSTimeInterval diff = [expectedDeparture timeIntervalSinceDate:scheduledDeparture];
        NSString *departureDelay = nil;
        if (diff > 0) {
            departureDelay = [NSString stringWithFormat:@"+%i", [[NSNumber numberWithFloat:diff / 60.0f] intValue]];
        }
        
        [train setDeparture:expectedDeparture];
        [train setDepartureDelay:departureDelay];
        
        // Arrival
        NSDate *scheduledArrival = [[NSRailConnection sharedInstance] dateForString:[[[element nodesForXPath:@"GeplandeAankomstTijd" error:nil] objectAtIndex:0] stringValue]];
        NSDate *expectedArrival = [[NSRailConnection sharedInstance] dateForString:[[[element nodesForXPath:@"ActueleAankomstTijd" error:nil] objectAtIndex:0] stringValue]];
        
        diff = [expectedArrival timeIntervalSinceDate:scheduledArrival];
        NSString *arrivalDelay = nil;
        if (diff > 0) {
            arrivalDelay = [NSString stringWithFormat:@"+%i", [[NSNumber numberWithFloat:diff / 60.0f] intValue]];
        }
        
        [train setArrival:expectedArrival];
        [train setArrivalDelay:arrivalDelay];
        
        // If the depature is in the past, don't add it
        diff = [expectedDeparture timeIntervalSinceNow];
        if (diff > 0 && [self shouldDisplayTrain:train]) {
            [trains addObject:train];
        }
    }
    
    return trains;
}

#pragma mark - Stations

- (NSString *)defaultDepartureStation
{
    return @"Haarlem";
}

- (NSString *)defaultArrivalStation
{
    return @"Amsterdam Centraal";
}

- (NSArray *)stations
{
    if (cachedStations) {
        return cachedStations;
    }
    
    NSMutableArray *stations = [NSMutableArray array];
    
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"ns" ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    NSArray *elements = [document nodesForXPath:@"//stations/station" error:nil];
    
    for (DDXMLElement *element in elements) {
        [stations addObject:@[
            [[[element nodesForXPath:@"name" error:nil] objectAtIndex:0] stringValue],
            [[[element nodesForXPath:@"lat" error:nil] objectAtIndex:0] stringValue],
            [[[element nodesForXPath:@"long" error:nil] objectAtIndex:0] stringValue],
            [[[element nodesForXPath:@"code" error:nil] objectAtIndex:0] stringValue]
        ]];
    }
    
    // update all locations to CLLocations
    NSMutableArray *newStations = [NSMutableArray array];
    
    [stations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *rawStation = (NSArray *)obj;
        
        // get the location of the station
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[rawStation objectAtIndex:1] doubleValue] longitude:[[rawStation objectAtIndex:2] doubleValue]];
        
        Station *station = [[Station alloc] init];
        [station setName:[rawStation objectAtIndex:0]];
        [station setCode:[rawStation objectAtIndex:3]];
        [station setLocation:location];
        
        [newStations addObject:station];
    }];
    
    cachedStations = newStations;
    
    return newStations;
}

@end