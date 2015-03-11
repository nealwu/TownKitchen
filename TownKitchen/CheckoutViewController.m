//
//  CheckoutViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutViewController.h"
#import "CheckoutOrderItemCell.h"
#import "MenuOption.h"

@interface CheckoutViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) NSArray *orderItems;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom setters

- (void)setOrder:(Order *)order {
    _order = order;
    [self reloadTableData];
    
    
//    NSMutableArray *mutableOrderItems = [NSMutableArray array];
//    for (NSString *menuItem in order.items) {
//        NSMutableDictionary *orderItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                          menuItem, @"menuItemName",
//                                        order.items[menuItem], @"quantity", nil];
//        [mutableOrderItems addObject:orderItem];
//    }
//    NSLog(@"mutableOrderItems: %@", mutableOrderItems);
//    
//    [mutableOrderItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        if (obj1[@"quantity"] > obj2[@"quantity"]) {
//            return NSOrderedAscending;
//        }
//        else if (obj1[@"quantity"] < obj2[@"quantity"]) {
//            return NSOrderedDescending;
//        }
//        else {
//            return NSOrderedSame;
//        }
//    }];
//    self.orderItems = [NSArray arrayWithArray:mutableOrderItems];
//        NSLog(@"%@", self.orderItems);
//    
//    // retrieve menu options from Parse
//    for (NSMutableDictionary *orderItem in self.orderItems) {
//        NSLog(@"looking for: %@", orderItem[@"menuItemName"]);
//        PFQuery *menuOptionQuery = [MenuOption query];
//        [menuOptionQuery whereKey:@"name" containsString:orderItem[@"menuItemName"]];
//        [menuOptionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            orderItem[@"menuOption"] = [objects firstObject];
//            NSLog(@"orderItem is now: %@", orderItem);
//            [self reloadTableData];
//        }];
//    }
}

#pragma mark Private Methods

- (void)setup{
    // tableView methods
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckoutOrderItemCell" bundle:nil] forCellReuseIdentifier:@"CheckoutOrderItemCell"];
    [self reloadTableData];
}

- (void)reloadTableData {
    [self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.order.menuOptionOrders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckoutOrderItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckoutOrderItemCell"];
    cell.menuOptionOrder = self.order.menuOptionOrders[indexPath.row];
    return cell;
}

#pragma mark Actions

- (IBAction)onPlaceOrder:(id)sender {
    
}


@end
