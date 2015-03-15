//
//  OrdersViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrdersViewController.h"
#import "OrderCell.h"
#import "ParseAPI.h"
#import "ReviewViewController.h"
#import "OrderStatusViewController.h"

@interface OrdersViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *orders;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Orders";

    self.orders = [[ParseAPI getInstance] ordersForUser:[PFUser user]];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCell" bundle:nil] forCellReuseIdentifier:@"OrderCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 10;
    [self.tableView reloadData];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    cell.order = self.orders[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ReviewViewController *rvc = [[ReviewViewController alloc] init];
    OrderStatusViewController *osvc = [[OrderStatusViewController alloc] init];
    osvc.order = self.orders[indexPath.row];
    [self.navigationController pushViewController:osvc animated:YES];
}

@end
