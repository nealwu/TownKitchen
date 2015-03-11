//
//  CheckoutViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutViewController.h"
#import "CheckoutOrderItemCell.h"

@interface CheckoutViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *orderItems;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom setters

- (void)setOrder:(Order *)order {
    _order = order;
    NSMutableArray *mutableOrderItems = [NSMutableArray array];
    for (NSString *menuItem in order.items) {
        [mutableOrderItems addObject:@{ @"menuItem" : menuItem, @"quantity" : order.items[menuItem] }];
    }
    NSLog(@"%@", mutableOrderItems);
    
    [mutableOrderItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (obj1[@"quantity"] > obj2[@"quantity"]) {
            return NSOrderedAscending;
        }
        else if (obj1[@"quantity"] < obj2[@"quantity"]) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];

    NSLog(@"%@", mutableOrderItems);
}

#pragma mark Private Methods

- (void)setup{
    // tableView methods
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckoutOrderItemCell" bundle:nil] forCellReuseIdentifier:@"CheckoutOrderItemCell"];
    
    // retrieve order objects from Parse
    
    for (NSString *orderItem in self.order.items) {
        
    }
    
    PFQuery *orderQuery = [Order query];
    

    
    /* PFQuery *inventoryQuery = [Inventory query];
    [inventoryQuery whereKey:@"dateOffered" greaterThanOrEqualTo:dateStart];
    [inventoryQuery whereKey:@"dateOffered" lessThanOrEqualTo:dateEnd];
    [inventoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"failed to find inventory objects, error: %@", error);
            return;
        }
        self.dayInventory = [[DayInventory alloc] init];
        self.dayInventory.inventoryItems = objects;
        NSLog(@"Today's Inventory: %@", self.dayInventory.inventoryItems);
        
        // Retrieve corresponding menu options
        
        for (Inventory *inventoryItem in self.dayInventory.inventoryItems) {
            PFQuery *menuOptionQuery = [MenuOption query];
            [menuOptionQuery whereKey:@"name" equalTo:inventoryItem.menuOption];
            [menuOptionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"failed to find menu option, error: %@", error);
                }
                inventoryItem.menuOptionObject = [objects firstObject];
                [self reloadAllTableViewData];
            }];
        }
    }]; */
    
}
#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.order.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckoutOrderItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckoutOrderItemCell"];
    
    cell.menuOptionOrder = nil;
    
    return cell;
}

#pragma mark Actions

- (IBAction)onPlaceOrder:(id)sender {
    
}


@end
