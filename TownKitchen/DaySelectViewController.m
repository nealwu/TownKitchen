//
//  DayViewController.m
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
#import "DayInventory.h"
#import "DateUtils.h"

@interface DaySelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *inventories;
@property (strong, nonatomic) NSMutableArray *uniqueInventories;

@end

@implementation DaySelectViewController

- (NSArray *)filterInventoriesByDate:(NSDate *)date {
    return [self.inventories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[DateUtils monthAndDayFromDate:((Inventory *) evaluatedObject).dateOffered] isEqual:[DateUtils monthAndDayFromDate:date]];
    }]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Town Kitchen";

    self.inventories = [[ParseAPI getInstance] dayInventories];
    NSLog(@"Inventories: %@", self.inventories);

    self.uniqueInventories = [NSMutableArray array];
    NSMutableSet *dates = [NSMutableSet set];

    for (Inventory *inventory in self.inventories) {
        inventory.imageURL = [[ParseAPI getInstance] imageURLForMenuOption:inventory.menuOption];
        NSString *monthAndDay = [DateUtils monthAndDayFromDate:inventory.dateOffered];

        if (![dates containsObject:monthAndDay]) {
            [self.uniqueInventories addObject:inventory];
            [dates addObject:monthAndDay];
        }
    }

//    Inventory *inventory = inventories[0];
//    NSLog(@"Inventory date offered: %@", inventory.dateOffered);
//    NSLog(@"Day of the week: %@", [self dayOfTheWeekFromDate:inventory.dateOffered]);
//    NSLog(@"Month and day: %@", [self monthAndDayFromDate:inventory.dateOffered]);
//    NSLog(@"Inventory menu option: %@", inventory.menuOption);

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
    Inventory *inventory = self.uniqueInventories[indexPath.row];
    OrderCreationViewController *ocvc = [[OrderCreationViewController alloc] init];
    
    NSArray *inventoryItems = @[@"inventory item 1 for selected day", @"inventory item 2 for selected day"];
    ocvc.inventoryItems = inventoryItems;
    
    [self.navigationController pushViewController:ocvc animated:YES];
}

@end
