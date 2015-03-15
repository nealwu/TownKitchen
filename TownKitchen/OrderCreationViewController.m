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
#import "MenuOptionOrder.h"
#import "Order.h"
#import "OrderCreationTableViewCell.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) OrderCreationTableViewCell *sizingCell;

@property (strong, nonatomic) NSArray *menuOptionShortnames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (strong, nonatomic) NSDictionary *shortNameToQuantity;

@end

@implementation OrderCreationViewController

#pragma mark View Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.title = [DateUtils monthAndDayFromDate:((Inventory *)self.dayInventory.inventoryItems[0]).dateOffered];

    [self setup];
    
    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCreationTableViewCell" bundle:nil] forCellReuseIdentifier:@"OrderCreationTableViewCell"];

    [self reloadAllTableViewData];
}

#pragma mark OrderCreationTableViewCellDelegate Methods

#pragma mark Actions

- (IBAction)onOrderButton:(id)sender {
    [self createOrder];
}

#pragma mark Private Methods

- (void)setup {
    // retrieve MenuOption objects
    NSMutableArray *mutableMenuOptionShortnames = [NSMutableArray array];
    NSMutableDictionary *mutableShortNameToQuantity = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutableShortNameToObject = [NSMutableDictionary dictionary];

    for (Inventory *inventoryItem in self.inventoryItems) {
        [mutableMenuOptionShortnames addObject:inventoryItem.menuOptionShortName];
        [mutableShortNameToQuantity addEntriesFromDictionary:@{ inventoryItem.menuOptionShortName : @0 }];
        
        PFQuery *menuOptionQuery = [MenuOption query];
        [menuOptionQuery whereKey:@"shortName" equalTo:inventoryItem.menuOptionShortName];
        [menuOptionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0) {
                [mutableShortNameToObject addEntriesFromDictionary:@{ inventoryItem.menuOptionShortName : [objects firstObject]}];
                
                self.menuOptionShortnames = [NSArray arrayWithArray:mutableMenuOptionShortnames];
                self.shortNameToQuantity = [NSDictionary dictionaryWithDictionary:mutableShortNameToQuantity];
                self.shortNameToObject = [NSDictionary dictionaryWithDictionary:mutableShortNameToObject];
//                [self reloadAllTableViewData];
            } else {
                NSLog(@"failed to find menu option, error: %@", error);
            }
        }];
    }
}

- (void)reloadAllTableViewData {
    [self.tableView reloadData];
}

- (void)createOrder {
//    Order *order = [Order object];
//    float orderPrice = 0;
//    NSMutableDictionary *items = [NSMutableDictionary dictionary];
//    NSMutableArray *menuOptionOrders = [NSMutableArray array];
//    
//    for (MenuOptionOrder *menuOptionOrder in self.menuOptionOrders) {
//        if ([menuOptionOrder.quantity isEqualToNumber:[NSNumber numberWithInt:0]]) {
//            continue;
//        }
//        [menuOptionOrders addObject:menuOptionOrder];
//        
//        NSDictionary *item = @{menuOptionOrder.menuOption.name : menuOptionOrder.quantity};
//        [items addEntriesFromDictionary:item];
//        orderPrice += [menuOptionOrder.totalPrice floatValue];
//    }
//    order.menuOptionOrders = [NSArray arrayWithArray:menuOptionOrders];
//    order.items = items;
//    order.price = [NSNumber numberWithFloat:orderPrice];
//    order.deliveryTime = ((Inventory *)self.dayInventory.inventoryItems[0]).dateOffered;
//    NSLog(@"Creating order: %@ with menuOptionOrders: %@", order, order.menuOptionOrders);
//    
//    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
//    checkoutViewController.order = order;
//    [self.navigationController pushViewController:checkoutViewController animated:YES];
}

- (void)onNext {
    LocationSelectViewController *lsvc = [[LocationSelectViewController alloc] init];
    [self.navigationController pushViewController:lsvc animated:YES];
}

#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inventoryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCreationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationTableViewCell"];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // initialize sizing cell
    if (!self.sizingCell) {
        self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationTableViewCell"];
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