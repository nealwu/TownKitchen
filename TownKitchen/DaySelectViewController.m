//
//  DaySelectViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectViewController.h"
#import "DayCell.h"
#import "ParseAPI.h"
#import "Inventory.h"
#import "UIImageView+AFNetworking.h"
#import "OrderCreationViewController.h"
#import "DateUtils.h"

@interface DaySelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *inventoryItems;
@property (strong, nonatomic) NSMutableArray *uniqueInventories;

@end

@implementation DaySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Town Kitchen";

    self.inventoryItems = [[ParseAPI getInstance] inventoryItems];
    self.uniqueInventories = [NSMutableArray array];
    NSMutableSet *dates = [NSMutableSet set];

    for (Inventory *inventory in self.inventoryItems) {
        inventory.imageURL = [[ParseAPI getInstance] menuOptionForShortName:inventory.menuOptionShortName].imageURL;
        NSString *monthAndDay = [DateUtils monthAndDayFromDate:inventory.dateOffered];

        if (![dates containsObject:monthAndDay]) {
            [self.uniqueInventories addObject:inventory];
            [dates addObject:monthAndDay];
        }
    }

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayCell" bundle:nil] forCellReuseIdentifier:@"DayCell"];
    self.tableView.rowHeight = self.tableView.frame.size.height / 3;
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uniqueInventories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Inventory *inventory = self.uniqueInventories[indexPath.row];
    DayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayCell" forIndexPath:indexPath];
    [cell.backgroundImageView setImageWithURL:[NSURL URLWithString:inventory.imageURL]];
    cell.dayLabel.text = [DateUtils dayOfTheWeekFromDate:inventory.dateOffered];
    cell.dateLabel.text = [DateUtils monthAndDayFromDate:inventory.dateOffered];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderCreationViewController *ocvc = [[OrderCreationViewController alloc] init];
    Inventory *inventory = self.uniqueInventories[indexPath.row];
    ocvc.inventoryItems = [[ParseAPI getInstance] inventoryItemsForDay:inventory.dateOffered];
    [self.navigationController pushViewController:ocvc animated:YES];
}

@end
