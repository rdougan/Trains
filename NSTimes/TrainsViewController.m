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
    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
    UIView *_headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    _headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 4, 200, 24);
    titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.shadowColor = [UIColor colorWithWhite:0 alpha:.4];
    titleView.shadowOffset = CGSizeMake(0, -1);
    titleView.text = NSLocalizedString(@"Trains", @"Trains");
    titleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:titleView];
    
    CGRect subtitleFrame = CGRectMake(0, 22, 200, 44-24);
    subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont systemFontOfSize:13];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.textColor = [UIColor colorWithWhite:1 alpha:.8];
    subtitleView.shadowColor = [UIColor colorWithWhite:0 alpha:.3];
    subtitleView.shadowOffset = CGSizeMake(0, -1);
    subtitleView.text = @"Haarlem → Amsterdam";
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:subtitleView];
    
    _headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.titleView = _headerTitleSubtitleView;
    
    // Tap recognizer for navigation title
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchStations)];
    
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    [self.navigationItem.titleView addGestureRecognizer:tapRecognizer];
}

#pragma mark - Trains

/**
 * Swaps the current stations
 */
- (void)switchStations
{
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    
    if ([subtitleView.text isEqualToString:@"Haarlem → Amsterdam"]) {
        subtitleView.text = @"Amsterdam → Haarlem";
        
        [sharedInstance setTo:@"Haarlem"];
        [sharedInstance setFrom:@"Amsterdam"];
    } else {
        subtitleView.text = @"Haarlem → Amsterdam";
        
        [sharedInstance setTo:@"Amsterdam"];
        [sharedInstance setFrom:@"Haarlem"];
    }
    
    [self fetchTrains:self];
}

/**
 * Fetches the latest trains from NS.nl
 */
- (void)fetchTrains:(id)sender
{
    NSMutableArray *allTrains = [NSMutableArray array];
    
    NSRailConnection *sharedInstance = [NSRailConnection sharedInstance];
    [sharedInstance fetchWithSuccess:^(NSArray *trains) {
        [allTrains addObjectsFromArray:trains];
        
        [sharedInstance fetchMoreWithSuccess:^(NSArray *moreTrains) {
            [allTrains addObjectsFromArray:moreTrains];
            
            [self setTrains:allTrains];
        }];
    }];
}

/**
 * Updates the `_objects` array with the trains, and handles all the insert/reload/delete animations in the TableView
 */
- (void)setTrains:(NSArray *)trains
{
    [[self refreshControl] endRefreshing];
    
    [_objects removeAllObjects];
    [_objects addObjectsFromArray:trains];
    
    [[self tableView] beginUpdates];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
    
    if ([trains count] == 0) {
        [self showMessage:NSLocalizedString(@"no_trains_found", @"No trains found") detail:NSLocalizedString(@"no_trains_found_detail", @"No trains found detail")];
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
    return 64.f;
}

@end
