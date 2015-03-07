//
//  OrderCreationViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationViewController.h"
#import "OrderCreationTableViewCell.h"
#import "DayInventory.h"
#import "Inventory.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrderCreationViewController

#pragma mark View Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    
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
    cell.menuOption = [(Inventory *)self.dayInventory.inventoryItems[indexPath.row] menuOptionObject];
    return cell;
}

#pragma mark Setup Methods

- (void)setup {
    // Retrieve all inventory items for today
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2015];
    [components setMonth:3];
    [components setDay:7];
    NSDate *date = [calendar dateFromComponents:components];
    NSLog(@"Date: %@", date);
    
    PFQuery *query = [Inventory query];
    [query whereKey:@"dateOffered" lessThanOrEqualTo:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"failed to find inventory objects: %@", error);
            return;
        }
        DayInventory *dayInventory = [[DayInventory alloc] init];
        dayInventory.inventoryItems = objects;
        NSLog(@"todayInventory: %@", dayInventory.inventoryItems);
    }];
}

#pragma mark System Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end