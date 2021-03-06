//
//  TrainsSelectorView.m
//  NSTimes
//
//  Created by Robert Dougan on 12/1/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "TrainsSelectorView.h"

#import "NSRailConnection.h"

#import "TrainsSelectorTextField.h"

#define TrainsSelectorViewHeight 64.0f
#define ItemPadding 5.0f
#define FieldHeight 25.0f
#define ButtonWidth 28.0f
#define StatusBarHeight 20.0f
#define ToolbarHeight 44.0f
#define KeyboardHeight 216.0f
#define NearbyDistance 2500.0f

typedef void (^TrainsSelectorStateBlock)(TrainsSelectorViewState state);

@interface TrainsSelectorView ()

@property (nonatomic, retain) TrainsSelectorTextField *fromField;
@property (nonatomic, retain) TrainsSelectorTextField *toField;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIButton *swapButton;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *filteredStations;
@property (nonatomic, retain) TrainsSelectorMaskView *maskView;

@property (readwrite, nonatomic, assign) TrainsSelectorViewState viewState;
@property (readwrite, nonatomic, copy) TrainsSelectorStateBlock trainsSelectorSateBlock;

@end

@implementation TrainsSelectorView {
    NSString *currentSearch;
    int nearbyStations;
}

@synthesize fromField = _fromField,
toField = _toField,
backgroundView = _backgroundView,
swapButton = _swapButton,
tableView = _tableView,
filteredStations = _filteredStations,
maskView = _maskView;

@synthesize from = _from,
to = _to,
currentLocation = _currentLocation;

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Mask
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = TrainsSelectorViewHeight;
        
        _maskView = [[TrainsSelectorMaskView alloc] initWithFrame:frame];
        [_maskView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_maskView setDelegate:self];
        [self addSubview:_maskView];
        
        // Background
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TrainsSelectorViewHeight)];
        [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        [_backgroundView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"selector_bg.png"]]];
        [self addSubview:_backgroundView];
        
        // Fields
        _fromField = [[TrainsSelectorTextField alloc] initWithFrame:CGRectMake(ItemPadding + ButtonWidth + ItemPadding, ItemPadding, self.frame.size.width - (ItemPadding * 3) - ButtonWidth, FieldHeight) withLabel:NSLocalizedString(@"From", @"From")];
        [_fromField setDelegate:self];
        [_fromField addTarget:self action:@selector(fromFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [_fromField setReturnKeyType:UIReturnKeySearch];
        [_fromField setEnablesReturnKeyAutomatically:YES];
        [self addSubview:_fromField];
        
        _toField = [[TrainsSelectorTextField alloc] initWithFrame:CGRectMake(ItemPadding + ButtonWidth + ItemPadding, ItemPadding + FieldHeight + ItemPadding, _fromField.frame.size.width, FieldHeight) withLabel:NSLocalizedString(@"To", @"To")];
        [_toField setDelegate:self];
        [_toField addTarget:self action:@selector(toFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [_toField setReturnKeyType:UIReturnKeySearch];
        [_toField setEnablesReturnKeyAutomatically:YES];
        [self addSubview:_toField];
        
        // Buttons
        _swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swapButton setAdjustsImageWhenHighlighted:NO];
        [_swapButton setBackgroundImage:[UIImage imageNamed:@"swap_button"] forState:UIControlStateNormal];
        [_swapButton setBackgroundImage:[UIImage imageNamed:@"swap_button_selected"] forState:UIControlStateHighlighted];
        [_swapButton setFrame:CGRectMake(ItemPadding, 17.0f, ButtonWidth, ButtonWidth)];
        [_swapButton addTarget:self action:@selector(swapStations) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_swapButton];
        
        // Table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TrainsSelectorViewHeight, self.frame.size.width, 200.0f) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHidden:YES];
        [self addSubview:_tableView];
        
        _filteredStations = [NSArray array];
        nearbyStations = 0;
    }
    return self;
}

#pragma mark - Setters

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    [self didChangeState];
}

- (void)setFrom:(Station *)from
{
    _from = from;
    [_fromField setText:[from name]];
}

- (void)setTo:(Station *)to
{
    _to = to;
    [_toField setText:[to name]];
}

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
    
    if (currentSearch) {
        [self searchForStation:currentSearch];
    }
}

#pragma mark - Submission

- (void)swapStations
{
    NSString *from = [_fromField text];
    
    [_fromField setText:[_toField text]];
    [_toField setText:from];
    
    if (![[_fromField text] isEqualToString:@""] && ![[_toField text] isEqualToString:@""]) {
        [self submit];
    }
}

- (void)submit
{
    currentSearch = nil;
    
    // Find the propercase version of the station
    NSArray *stations = [[NSRailConnection sharedInstance] stations];
    
    _from = [stations objectAtIndex:[stations indexOfObjectPassingTest:^BOOL(id station, NSUInteger idx, BOOL *stop) {
        NSString *stationName = [(Station *)station name];

        return ([[stationName lowercaseString] isEqualToString:[[_fromField text] lowercaseString]]) ? YES : NO;
    }]];
    
    _to = [stations objectAtIndex:[stations indexOfObjectPassingTest:^BOOL(id station, NSUInteger idx, BOOL *stop) {
        NSString *stationName = [(Station *)station name];
        
        return ([[stationName lowercaseString] isEqualToString:[[_toField text] lowercaseString]]) ? YES : NO;
    }]];
    
    // Reset the filtered stations
    _filteredStations = [NSArray array];
    
    // Hide the tableview
    [UIView animateWithDuration:0.2f animations:^{
        [_tableView setAlpha:0];
    } completion:^(BOOL finished) {
        [_tableView setHidden:YES];
    }];
    
    // Hide the keyboard
    [self endEditing:YES];
    
    if ([_delegate respondsToSelector:@selector(trainsSelectorView:didCompleteSearchWithFrom:to:)]) {
        objc_msgSend(_delegate, @selector(trainsSelectorView:didCompleteSearchWithFrom:to:), self, _from, _to);
    }
}

- (void)cancel
{
    currentSearch = nil;
    
    if (![_tableView isHidden]) {
        [_fromField resignFirstResponder];
        [_toField resignFirstResponder];
        
        [UIView animateWithDuration:0.2f animations:^{
            [_tableView setAlpha:0];
        } completion:^(BOOL finished) {
            [_tableView setHidden:YES];
        }];
    }
    
    if ([_delegate respondsToSelector:@selector(trainsSelectorViewDidCancel:)]) {
        [_delegate performSelector:@selector(trainsSelectorViewDidCancel:) withObject:self];
    }
}

#pragma mark - Field changes

- (void)didChangeState
{
    if (![[_fromField text] isEqualToString:@""] && ![[_toField text] isEqualToString:@""]) {
        self.viewState = TrainsSelectorViewStateValid;
    } else {
        self.viewState = TrainsSelectorViewStateInvalid;
    }
    
    if (self.trainsSelectorSateBlock) {
        self.trainsSelectorSateBlock(self.viewState);
    }
}

- (void)setStateChangeBlock:(void (^)(TrainsSelectorViewState state))block
{
    self.trainsSelectorSateBlock = block;
}

- (void)fromFieldChanged:(id)sender
{
    [self searchForStation:[_fromField text]];
    
    [self didChangeState];
}

- (void)toFieldChanged:(id)sender
{
    [self searchForStation:[_toField text]];
    
    [self didChangeState];
}

#pragma - TableView search results

- (void)searchForStation:(NSString *)station
{
    currentSearch = station;
    nearbyStations = 0;
    
    NSArray *stations = [[NSRailConnection sharedInstance] stations];
    
    if ([_tableView isHidden]) {
        [self resizeTableView];
        [_tableView setHidden:NO];
        [_tableView setAlpha:0];
        
        [UIView animateWithDuration:.2f animations:^{
            [_tableView setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self resizeTableView];
        }];
    }
    
    NSMutableArray *newStations = [NSMutableArray array];
    
    [stations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL found = NO;
        
        NSString *stationName = [(Station *)obj name];
        CLLocation *stationLocation = [(Station *)obj location];
        
        // Finding stations
        if (![station isEqualToString:@""]) {
            NSRange range = [[stationName lowercaseString] rangeOfString:[station lowercaseString]];
            found = (range.length > 0) ? YES : NO;
        } else {
            found = YES;
        }
        
        // Nearby stations
        if (found && stationLocation && [stationLocation isKindOfClass:[CLLocation class]]) {
            CLLocationDistance distance = [stationLocation distanceFromLocation:_currentLocation];
            
            if (distance < NearbyDistance) {
                nearbyStations = nearbyStations + 1;
            }
            
            [newStations addObject:@[stationName, stationLocation, [NSNumber numberWithDouble:distance]]];
        } else if (found) {
            [newStations addObject:@[stationName]];
        }
    }];
    
    _filteredStations = [newStations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first;
        NSString *second;
        
        if ([obj1 count] > 1 && [obj2 count] > 1) {
            first = [(NSArray *)obj1 objectAtIndex:2];
            second = [(NSArray *)obj2 objectAtIndex:2];
        } else {
            first = [(NSArray *)obj1 objectAtIndex:0];
            second = [(NSArray *)obj2 objectAtIndex:0];
        }
        
        return [first compare:second];
    }];
    
    [_tableView reloadData];
}

- (void)resizeTableView
{
    // Get the correct size for the tableView
    CGRect frame = [_tableView frame];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    frame.size.height = screenFrame.size.height - StatusBarHeight - ToolbarHeight - KeyboardHeight - TrainsSelectorViewHeight;
    
    [_tableView setFrame:frame];
    
    // Set the correct size for this view
    frame = self.frame;
    frame.size.height = frame.size.height + _tableView.frame.size.height;
    
    [self setFrame:frame];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _fromField) {
        [self searchForStation:[_fromField text]];
    } else {
        [self searchForStation:[_toField text]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_fromField == textField) {
        if ([[_fromField text] isEqualToString:@""]) {
            return NO;
        } else if ([[_toField text] isEqualToString:@""]) {
            [_toField becomeFirstResponder];
        } else {
            [self submit];
        }
    } else if (_toField == textField) {
        if ([[_toField text] isEqualToString:@""]) {
            return NO;
        } else if ([[_fromField text] isEqualToString:@""]) {
            [_fromField becomeFirstResponder];
        } else {
            [self submit];
        }
    }
    
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (nearbyStations > 0 && section == 0) {
        return NSLocalizedString(@"Nearby Stations", @"Nearby Stations");
    } else if (nearbyStations > 0) {
        return NSLocalizedString(@"More Stations", @"Other Stations");
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nearbyStations > 0 && [_filteredStations count] > nearbyStations) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nearbyStations > 0 && section == 0) {
        return nearbyStations;
    } else if (nearbyStations > 0) {
        return [_filteredStations count] - nearbyStations;
    }
    
    return [_filteredStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    int index = 0;
    
    if (nearbyStations > 0 && [indexPath section] == 0) {
        index = [indexPath row];
    } else if (nearbyStations > 0) {
        index = [indexPath row] + nearbyStations;
    } else {
        index = [indexPath row];
    }
    
    NSArray *station = [_filteredStations objectAtIndex:index];
    NSString *stationName = [station objectAtIndex:0];
    
    [cell.textLabel setText:stationName];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = 0;
    
    if (nearbyStations > 0 && [indexPath section] == 0) {
        index = [indexPath row];
    } else if (nearbyStations > 0) {
        index = [indexPath row] + nearbyStations;
    } else {
        index = [indexPath row];
    }
    
    NSArray *station = [_filteredStations objectAtIndex:index];
    NSString *stationName = [station objectAtIndex:0];
    
    if ([_fromField isFirstResponder]) {
        [_fromField setText:stationName];
        
        if ([[_toField text] isEqualToString:@""] || [_toField text] == nil) {
            [_toField becomeFirstResponder];
        } else {
            [self submit];
        }
    } else if ([_toField isFirstResponder]) {
        [_toField setText:stationName];
        
        if ([[_fromField text] isEqualToString:@""] || [_fromField text] == nil) {
            [_fromField becomeFirstResponder];
        } else {
            [self submit];
        }
    }
}

#pragma mark - TrainsSelectorMaskViewDelegate
- (void)trainsMaskViewTouchesBegan:(TrainsSelectorMaskView *)maskView
{
    [self cancel];
}

@end
