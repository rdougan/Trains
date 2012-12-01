//
//  AppDelegate.m
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#import "AFNetworkActivityIndicatorManager.h"
#import "TrainsViewController.h"

@implementation AppDelegate {
    TrainsViewController *trainsViewController;
    NSTimer *fetchTimer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Crashlytics
    [Crashlytics startWithAPIKey:@"6ef68195318583ebfc3e0a80408adacc505f0764"];
    
    // Enable Activity Indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Trains view controller
    trainsViewController = [[TrainsViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:trainsViewController];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self stopFetchTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [trainsViewController switchStationsIfNeeded];
    [trainsViewController showRefreshControl];
    
    [self startFetchTimer];
}

#pragma mark - Train fetching

- (void)timerWithInterval:(float)interval
{
    if (fetchTimer) {
        [fetchTimer invalidate];
        fetchTimer = nil;
    }
    
    fetchTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:trainsViewController
                                          selector:@selector(fetchTrains:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)startFetchTimer
{
    if (fetchTimer) {
        return;
    }
    
    [trainsViewController fetchTrains:self];
    
    [self timerWithInterval:60.0f];
}

- (void)stopFetchTimer
{
    if (!fetchTimer) {
        return;
    }
    
    [fetchTimer invalidate];
    fetchTimer = nil;
}

@end
