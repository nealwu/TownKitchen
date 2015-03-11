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
#import "LocationSelectViewController.h"
#import "MenuOptionOrder.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource, OrderCreationTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuOptions;
@property (strong, nonatomic) NSMutableArray *menuOptionOrders;  // array of MenuOptionOrder objects
@property (strong, nonatomic) OrderCreationTableViewCell *sizingCell;

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

#pragma mark OrderCreationTableViewCellDelegate Methods

- (void)orderCreationTableViewCell:(OrderCreationTableViewCell *)cell didUpdateMenuOptionOrder:(MenuOptionOrder *)menuOptionOrder {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.menuOptionOrders[indexPath.row] = menuOptionOrder;
    NSLog(@"Updating order. Array of orders: %@", self.menuOptionOrders);
}

- (void)orderCreationTableViewCellDidClearMenuOptionOrder:(OrderCreationTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.menuOptionOrders[indexPath.row] = nil;
    NSLog(@"Clearing order. Array of orders: %@", self.menuOptionOrders);
}

#pragma mark Actions

- (IBAction)onOrderButton:(id)sender {
    
}

#pragma mark Private Methods

- (void)setup {
    
    self.menuOptionOrders = [NSMutableArray array];
    
    // Customize navigation bar
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onNext)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // Retrieve all inventory items for today
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2015];
    [components setMonth:3];
    [components setDay:7];
    NSDate *dateStart = [calendar dateFromComponents:components];
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate *dateEnd = [NSDate dateWithTimeInterval:oneDay sinceDate:dateStart];
    //    NSLog(@"start date: %@, end date %@", dateStart, dateEnd);
    
    PFQuery *inventoryQuery = [Inventory query];
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
                [self.tableView reloadData];
            }];
        }
    }];
}

- (void)onNext {
    LocationSelectViewController *lsvc = [[LocationSelectViewController alloc] init];
    [self.navigationController pushViewController:lsvc animated:YES];
}

#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dayInventory.inventoryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCreationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationTableViewCell"];
    cell.menuOption = [(Inventory *)self.dayInventory.inventoryItems[indexPath.row] menuOptionObject];
    cell.delegate = self;
    
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
    self.sizingCell.menuOption = [(Inventory *)self.dayInventory.inventoryItems[indexPath.row] menuOptionObject];
    
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