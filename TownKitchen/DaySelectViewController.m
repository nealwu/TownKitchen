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

@interface DaySelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *inventories;
@property (strong, nonatomic) NSMutableArray *uniqueInventories;

@end

@implementation DaySelectViewController

- (NSString *)dayOfTheWeekFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    return [formatter stringFromDate:date];
}

- (NSString *)monthAndDayFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d"];
    return [formatter stringFromDate:date];
}

- (NSArray *)filterInventoriesByDate:(NSDate *)date {
    return [self.inventories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[self monthAndDayFromDate:((Inventory *) evaluatedObject).dateOffered] isEqual:[self monthAndDayFromDate:date]];
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
        NSString *monthAndDay = [self monthAndDayFromDate:inventory.dateOffered];

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
    cell.dayLabel.text = [self dayOfTheWeekFromDate:inventory.dateOffered];
    cell.dateLabel.text = [self monthAndDayFromDate:inventory.dateOffered];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Inventory *inventory = self.uniqueInventories[indexPath.row];
    OrderCreationViewController *ocvc = [[OrderCreationViewController alloc] init];
    DayInventory *dayInventory = [[DayInventory alloc] init];
    dayInventory.inventoryItems = [self filterInventoriesByDate:inventory.dateOffered];
    ocvc.dayInventory = dayInventory;
    NSLog(@"Inventory items: %@", dayInventory.inventoryItems);
    [self.navigationController pushViewController:ocvc animated:YES];
}

@end
