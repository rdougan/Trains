//
//  LocationManager.m
//  NSTimes
//
//  Created by Robert Dougan on 12/2/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager {
    CLLocationManager *locationManager;
    
    int locationCount;
}

@synthesize currentLocation = _currentLocation,
delegate = _delegate;

static LocationManager *sharedInstance = nil;

+ (LocationManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[LocationManager alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDelegate:self];
    }
    return self;
}

- (void)updateLocation
{
    [locationManager startUpdatingLocation];
    
    if (_delegate) {
        [_delegate performSelector:@selector(locationManager:didUpdateToLocation:) withObject:self withObject:_currentLocation];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (locationCount < 15) {
        locationCount = locationCount + 1;
        
        if (!_currentLocation || ([newLocation horizontalAccuracy] > [_currentLocation horizontalAccuracy])) {
            _currentLocation = newLocation;
            
            if (_delegate) {
                [_delegate performSelector:@selector(locationManager:didUpdateToLocation:) withObject:self withObject:_currentLocation];
            }
        }
    } else {
        [locationManager stopUpdatingLocation];
        locationCount = 0;
        
        if (_delegate) {
            [_delegate performSelector:@selector(locationManager:didUpdateToLocation:) withObject:self withObject:_currentLocation];
        }
    }
}

@end
