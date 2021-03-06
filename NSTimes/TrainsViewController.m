//
//  TrainsViewController.m
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsViewController.h"

#import "Train.h"
#import "NSRailConnection.h"

#import "TrainsTableViewCell.h"
#import "TrainsMessageView.h"

@interface TrainsViewController () {
    NSMutableArray *_objects;
    
    UILabel *titleView;
    UILabel *subtitleView;
    
    TrainsMessageView *messageView;
    TrainsSelectorView *selectionView;
}
@end

@implementation TrainsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initTitleView];
        _objects = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Location Manager
    LocationManager *locationManager = [LocationManager sharedInstance];
    [locationManager setDelegate:self];
    [locationManager updateLocation];
    
    [[self tableView] setRowHeight:64.f];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    // Setup the message view
    messageView = [[TrainsMessageView alloc] init];
    [messageView setHidden:YES];

    [self.view addSubview:messageView];
    
    // Setup the pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchTrains:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [[self refreshControl] beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setFrame:self.view.superview.bounds];
    
    CGRect viewFrame = CGRectMake(0, 0, self.view.frame.size.width, 62.0f);
    [messageView setFrame:viewFrame];
}

/**
 * Sets up the custom title view which adds a subtitle and tapable navigation bar
 */
- (void)initTitleView
{
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    
    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, self.view.bounds.size.width, 44.0f);
    UIView *headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    [headerTitleSubtitleView setBackgroundColor:[UIColor clearColor]];
    [headerTitleSubtitleView setAutoresizesSubviews:YES];
    
    // Title
    CGRect titleFrame = CGRectMake(0, 4.0f, headerTitleSubtitleFrame.size.width, 24.0f);
    titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0f];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.shadowColor = [UIColor colorWithWhite:0 alpha:.4f];
    titleView.shadowOffset = CGSizeMake(0, -1.0f);
    titleView.text = NSLocalizedString(@"Trains", @"Trains");
    titleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:titleView];
    
    // Subtitle
    CGRect subtitleFrame = CGRectMake(0, 22.0f, headerTitleSubtitleFrame.size.width, 20.0f);
    subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont systemFontOfSize:13.0f];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.textColor = [UIColor colorWithWhite:1.0f alpha:.8f];
    subtitleView.shadowColor = [UIColor colorWithWhite:0 alpha:.3f];
    subtitleView.shadowOffset = CGSizeMake(0, -1.0f);
    subtitleView.text = [NSString stringWithFormat:@"%@ → %@", [[sharedInstance from] name], [[sharedInstance to] name]];
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:subtitleView];
    
    [headerTitleSubtitleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    
    self.navigationItem.titleView = headerTitleSubtitleView;
    
    // Tap recognizer for navigation title
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchStations)];
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    [self.navigationItem.titleView addGestureRecognizer:tapRecognizer];
}

- (void)showRefreshControlAndFetch
{
    [[self refreshControl] beginRefreshing];
    
    if ([[self tableView] contentOffset].y != -44.0f) {
        [[self tableView] setContentOffset:CGPointMake(0, 0)];
        
        [UIView animateWithDuration:.3f animations:^{
            [[self tableView] setContentOffset:CGPointMake(0, -44.0)];
        } completion:^(BOOL finished) {
            [self fetchTrains:self];
        }];
    } else {
        [self fetchTrains:self];
    }
}

#pragma mark - Station Selector

- (void)route:(id)sender
{
    [selectionView submit];
}

#pragma mark - Trains

/**
 * Swaps the current stations
 */
- (void)switchStations
{
    if (selectionView && ![selectionView isHidden]) {
        [selectionView cancel];
        return;
    }
    
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    
    if (!selectionView) {
        selectionView = [[TrainsSelectorView alloc] initWithFrame:CGRectMake(0, -64.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        [selectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        [selectionView setDelegate:self];
        [[self tableView] addSubview:selectionView];
    }
    
    LocationManager *locationManager = [LocationManager sharedInstance];
    [locationManager updateLocation];
    
    [selectionView setHidden:NO];
    [selectionView setFrom:[sharedInstance from]];
    [selectionView setTo:[sharedInstance to]];
    
    [[self tableView] setScrollEnabled:NO];
    [[self tableView] setContentOffset:CGPointMake(0, -64.0f) animated:YES];
}

- (void)switchStationsIfNeeded
{
//    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
//    
//    if (!([[sharedInstance from] isEqualToString:@"Amsterdam"] || [[sharedInstance from] isEqualToString:@"Haarlem"]) || !([[sharedInstance to] isEqualToString:@"Amsterdam"] || [[sharedInstance to] isEqualToString:@"Haarlem"])) {
//        return;
//    }
//    
//    NSDate *date = [NSDate date];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:date];
//    NSInteger hour = [components hour];
//    
//    if (hour > 13 || hour < 4) {
//        [sharedInstance setTo:@"Haarlem"];
//        [sharedInstance setFrom:@"Amsterdam"];
//    } else {
//        [sharedInstance setTo:@"Amsterdam"];
//        [sharedInstance setFrom:@"Haarlem"];
//    }
}

/**
 * Fetches the latest trains from NS.nl
 */
- (void)fetchTrains:(id)sender
{
    if (selectionView && ![selectionView isHidden]) {
        return;
    }
    
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    
    if ([sharedInstance from] && [sharedInstance to]) {
        subtitleView.text = [NSString stringWithFormat:@"%@ → %@", [[sharedInstance from] name], [[sharedInstance to] name]];
    }
    
    [sharedInstance fetchWithSuccess:^(NSArray *trains) {
        [self setTrains:trains];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        
        // Empty the schedule
        _objects = [NSArray array];
        [[self tableView] reloadData];
        
        if ([error code] == -1009) {
            [self showMessage:NSLocalizedString(@"no_connection", @"Something went wrong")
                       detail:NSLocalizedString(@"no_connection_detail", @"Please try again in a few minutes")];
        } else {
            [self showMessage:NSLocalizedString(@"trains_failure", @"Something went wrong")
                       detail:NSLocalizedString(@"trains_failure_detail", @"Please try again in a few minutes")];
        }
    }];
}

/**
 * Updates the `_objects` array with the trains, and handles all the insert/reload/delete animations in the TableView
 */
- (void)setTrains:(NSArray *)trains
{
    [[self refreshControl] endRefreshing];
    
    _objects = [_objects mutableCopy];
    
    [_objects removeAllObjects];
    [_objects addObjectsFromArray:trains];
    
    [[self tableView] beginUpdates];
    // This causes the view to jump back to 0/-refreshControlHeight when selectionView is not hidden
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (selectionView && ![selectionView isHidden]) {
        [[self tableView] setContentOffset:CGPointMake(0, -64.0f)];
    }
    [[self tableView] endUpdates];
    
    if ([trains count] == 0) {
        [self showMessage:NSLocalizedString(@"no_trains_found", @"No trains found")
                   detail:NSLocalizedString(@"no_trains_found_detail", @"No trains found detail")];
    } else {
        [self hideMessage];
    }
}

#pragma mark - Message View

- (void)showMessage:(NSString *)message detail:(NSString *)detail
{
    if (![messageView isHidden]) {
        [messageView setText:message detail:detail];
        return;
    }
    
    [messageView setAlpha:0.0f];
    [messageView setHidden:NO];
    [messageView setText:message detail:detail];
    
    [UIView animateWithDuration:.1f animations:^{
        [messageView setAlpha:1.0f];
    }];
}

- (void)hideMessage
{
    if ([messageView isHidden]) {
        return;
    }
    
    [UIView animateWithDuration:.1f animations:^{
        [messageView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [messageView setHidden:YES];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TrainsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TrainsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    Train *train = _objects[indexPath.row];
    [cell setTrain:train];

    return (UITableViewCell *)cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

#pragma mark - TrainsSelectorViewDelegate

- (void)trainsSelectorView:(TrainsSelectorView *)trainsSelectorView didCompleteSearchWithFrom:(Station *)from to:(Station *)to
{
    [[self tableView] setScrollEnabled:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    [sharedInstance setFrom:from];
    [sharedInstance setTo:to];
    
    [UIView animateWithDuration:0.25f animations:^{
        [[self tableView] setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [selectionView setHidden:YES];
        [self fetchTrains:self];
    }];
}

- (void)trainsSelectorViewDidCancel:(TrainsSelectorView *)trainsSelectorView
{
    if (!selectionView || [selectionView isHidden]) {
        return;
    }
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    [UIView animateWithDuration:0.25f animations:^{
        [[self tableView] setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [[self tableView] setScrollEnabled:YES];
        [selectionView setHidden:YES];
    }];
}

#pragma mark - LocationManagerDelegate

- (void)locationManager:(LocationManager *)locationManager didUpdateToLocation:(CLLocation *)location
{
    if (selectionView) {
        [selectionView setCurrentLocation:location];
    }
}

@end
