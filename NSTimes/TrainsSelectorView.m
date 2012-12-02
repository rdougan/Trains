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

#define ItemPadding 5.0f
#define FieldHeight 25.0f
#define ButtonWidth 28.0f
#define StatusBarHeight 20.0f
#define ToolbarHeight 44.0f
#define KeyboardHeight 216.0f

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

@implementation TrainsSelectorView

@synthesize fromField = _fromField,
toField = _toField,
backgroundView = _backgroundView,
swapButton = _swapButton,
tableView = _tableView,
filteredStations = _filteredStations,
maskView = _maskView;

@synthesize from = _from,
to = _to;

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Mask
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = 65.0f;
        
        _maskView = [[TrainsSelectorMaskView alloc] initWithFrame:frame];
        [_maskView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_maskView setDelegate:self];
        [self addSubview:_maskView];
        
        // Background
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 65.0f)];
        [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        [_backgroundView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"selector_bg.png"]]];
        [self addSubview:_backgroundView];
        
        // Fields
        _fromField = [[TrainsSelectorTextField alloc] initWithFrame:CGRectMake(ItemPadding + ButtonWidth + ItemPadding, ItemPadding, self.frame.size.width - (ItemPadding * 3) - ButtonWidth, FieldHeight) withLabel:NSLocalizedString(@"From", @"From")];
        [_fromField setDelegate:self];
        [_fromField addTarget:self action:@selector(fromFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_fromField];
        
        _toField = [[TrainsSelectorTextField alloc] initWithFrame:CGRectMake(ItemPadding + ButtonWidth + ItemPadding, ItemPadding + FieldHeight + ItemPadding, _fromField.frame.size.width, FieldHeight) withLabel:NSLocalizedString(@"To", @"To")];
        [_toField setDelegate:self];
        [_toField addTarget:self action:@selector(toFieldChanged:) forControlEvents:UIControlEventEditingChanged];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65.0f, self.frame.size.width, 200.0f) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHidden:YES];
        [self addSubview:_tableView];
        
        _filteredStations = [NSArray array];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    [self didChangeState];
}

- (void)setFrom:(NSString *)from
{
    _from = from;
    [_fromField setText:from];
}

- (void)setTo:(NSString *)to
{
    _to = to;
    [_toField setText:to];
}

- (void)swapStations
{
    NSString *from = [_fromField text];
    
    [_fromField setText:[_toField text]];
    [_toField setText:from];
}

- (void)maskTap:(UITapGestureRecognizer *)tapGesture
{
    [self cancel];
}

- (void)submit
{
    // Find the propercase version of the station
    NSArray *stations = [[NSRailConnection sharedInstance] stations];
    
    _from = [stations objectAtIndex:[stations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([[(NSString *)obj lowercaseString] isEqualToString:[[_fromField text] lowercaseString]]) ? YES : NO;
    }]];
    
    _to = [stations objectAtIndex:[stations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([[(NSString *)obj lowercaseString] isEqualToString:[[_toField text] lowercaseString]]) ? YES : NO;
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
    
    _filteredStations = [stations objectsAtIndexes:[stations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL found = NO;
        
        if (![station isEqualToString:@""]) {
            NSRange range = [[(NSString *)obj lowercaseString] rangeOfString:[station lowercaseString]];
            found = (range.length > 0) ? YES : NO;
        } else {
            found = YES;
        }
        
        // Do not show any stations currently typed
        if ([[(NSString *)obj lowercaseString] isEqualToString:[[_fromField text] lowercaseString]] || [[(NSString *)obj lowercaseString] isEqualToString:[[_toField text] lowercaseString]]) {
            found = NO;
        }
        
        return found;
    }]];
    
    [_tableView reloadData];
}

- (void)resizeTableView
{
    // Get the correct size for the tableView
    CGRect frame = [_tableView frame];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    frame.size.height = screenFrame.size.height;
    
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
        if ([[_toField text] isEqualToString:@""]) {
            [_toField becomeFirstResponder];
        } else {
            [self submit];
        }
    } else if (_toField == textField) {
        if ([[_fromField text] isEqualToString:@""]) {
            [_fromField becomeFirstResponder];
        } else {
            [self submit];
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filteredStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:[_filteredStations objectAtIndex:[indexPath row]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *station = [_filteredStations objectAtIndex:[indexPath row]];
    
    if ([_fromField isFirstResponder]) {
        [_fromField setText:station];
        
        if ([[_toField text] isEqualToString:@""]) {
            [_toField becomeFirstResponder];
        } else {
            [self submit];
        }
    } else if ([_toField isFirstResponder]) {
        [_toField setText:station];
        
        if ([[_fromField text] isEqualToString:@""]) {
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
