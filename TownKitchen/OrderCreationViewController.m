//
//  OrderCreationViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationViewController.h"

#import "CheckoutViewController.h"
#import "DateUtils.h"
#import "Inventory.h"
#import "LocationSelectViewController.h"
#import "Order.h"
#import "OrderCreationCell.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource, OrderCreationTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) OrderCreationCell *sizingCell;

@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (strong, nonatomic) NSMutableDictionary *shortNameToQuantity;

@end

@implementation OrderCreationViewController

#pragma mark View Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    Inventory *firstInventory = self.inventoryItems[0];
    self.title = [DateUtils monthAndDayFromDate:firstInventory.dateOffered];

    [self setup];
    
    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCreationCell" bundle:nil] forCellReuseIdentifier:@"OrderCreationCell"];
    [self.tableView reloadData];
}

#pragma mark OrderCreationTableViewCellDelegate Methods

- (void)orderCreationTableViewCell:(OrderCreationCell *)cell didUpdateQuantity:(NSNumber *)quantity {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    self.shortNameToQuantity[shortName] = quantity;
    NSLog(@"updated quantity for %@, quantities dictionary is now: %@", shortName, self.shortNameToQuantity);
}

#pragma mark Actions

- (IBAction)onOrderButton:(id)sender {
    Order *order = [Order object];
    order.items = self.shortNameToQuantity;
    order.user = [PFUser currentUser];
    order.deliveryDateAndTime = [(Inventory *)[self.inventoryItems firstObject] dateOffered];
    NSLog(@"Creating order: %@", order);

    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
    checkoutViewController.order = order;
    [self.navigationController pushViewController:checkoutViewController animated:YES];
}

#pragma mark Private Methods

- (void)setup {
    // retrieve MenuOption objects
    NSMutableArray *mutableMenuOptionShortnames = [NSMutableArray array];
    NSMutableDictionary *mutableShortNameToObject = [NSMutableDictionary dictionary];
    self.shortNameToQuantity = [NSMutableDictionary dictionary];

    for (Inventory *inventoryItem in self.inventoryItems) {
        [mutableMenuOptionShortnames addObject:inventoryItem.menuOptionShortName];
        [self.shortNameToQuantity addEntriesFromDictionary:@{ inventoryItem.menuOptionShortName : @0 }];
        
        PFQuery *menuOptionQuery = [MenuOption query];
        [menuOptionQuery whereKey:@"shortName" equalTo:inventoryItem.menuOptionShortName];
        [menuOptionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0) {
                [mutableShortNameToObject addEntriesFromDictionary:@{ inventoryItem.menuOptionShortName : [objects firstObject]}];
                
                self.menuOptionShortNames = [NSArray arrayWithArray:mutableMenuOptionShortnames];
                self.shortNameToObject = [NSDictionary dictionaryWithDictionary:mutableShortNameToObject];
                [self.tableView reloadData];
            } else {
                NSLog(@"failed to find menu option, error: %@", error);
            }
        }];
    }
}

#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptionShortNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCreationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationCell"];
    cell.delegate = self;
    
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    cell.menuOption = self.shortNameToObject[shortName];
    cell.quantity = self.shortNameToQuantity[shortName];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // initialize sizing cell
    if (!self.sizingCell) {
        self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationCell"];
    }
    
    // populate cell with same data as visible cell
    [self.sizingCell setNeedsUpdateConstraints];
    [self.sizingCell updateConstraintsIfNeeded];
    
    // set cell width to same as width as tableView
    self.sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.sizingCell.bounds));
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    
    // get the height of sizing cell
    CGFloat height = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;  // compensate for cell separators
    
    return height;
}

#pragma mark System Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end