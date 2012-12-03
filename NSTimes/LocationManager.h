//
//  LocationManager.h
//  NSTimes
//
//  Created by Robert Dougan on 12/2/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LocationManager;

@protocol LocationManagerDelegate <NSObject>
- (void)locationManager:(LocationManager *)locationManager didUpdateToLocation:(CLLocation *)location;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager *)sharedInstance;

@property (readonly, nonatomic) CLLocation *currentLocation;
@property (nonatomic, assign) id <LocationManagerDelegate> delegate;

- (void)updateLocation;

@end
