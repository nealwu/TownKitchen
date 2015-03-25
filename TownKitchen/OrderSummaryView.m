//
//  OrderSummaryView.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderSummaryView.h"
#import "TKMenuOptionCell.h"
#import "ParseAPI.h"

@interface OrderSummaryView () <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDateAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddressLabel;

@property (strong, nonatomic) NSArray *menuOptions;

@end

@implementation OrderSummaryView

+ (NSDateFormatter *)deliveryDateAndTimeFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"M/d/yy h:mm a";
    });
    return formatter;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
        [nib instantiateWithOwner:self options:0];
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        
        UINib *cellNib = [UINib nibWithNibName:@"TKMenuOptionCell" bundle:nil];
        [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TKMenuOptionCell"];
    }
    return self;
}

- (void)setOrder:(Order *)order {
    NSLog(@"entering setOrder: order = %@", order);
    _order = order;
    self.menuOptions = [order.items allKeys];
    [self updateSubviews];
    [self.tableView reloadData];
}

- (void)updateSubviews {
    [self.order.user fetchIfNeeded];
    self.userNameLabel.text = self.order.user.username;
    self.deliveryDateAndTimeLabel.text = [[OrderSummaryView deliveryDateAndTimeFormatter] stringFromDate:self.order.deliveryTimeUtc];
    self.deliveryAddressLabel.text = self.order.deliveryAddress;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    self.tableViewHeightConstraint.constant = self.tableView.rowHeight * self.menuOptions.count;
    [super updateConstraints];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TKMenuOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKMenuOptionCell"];
    NSString *shortName = self.menuOptions[indexPath.row];
    cell.menuOption = self.order.shortNameToMenuOptionObject[shortName];
    cell.quantity = [self.order.items[shortName] integerValue];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
    return cell;
}

@end
