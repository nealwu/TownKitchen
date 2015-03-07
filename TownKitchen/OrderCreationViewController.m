//
//  OrderCreationViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationViewController.h"
#import "OrderCreationTableViewCell.h"
#import "Inventory.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrderCreationViewController

#pragma mark View Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCreationTableViewCell" bundle:nil] forCellReuseIdentifier:@"OrderCreationTableViewCell"];
}



#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dayInventory.inventoryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCreationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationTableViewCell"];
    cell.menuOption = [(Inventory *)self.dayInventory.inventoryItems[indexPath.row] menuOption];
    return cell;
}

#pragma mark System Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
