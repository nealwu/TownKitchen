//
//  DeliveryStatusViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Bolts.h>
#import "DeliveryStatusViewController.h"
#import "OrderStatusViewController.h"
#import "ParseAPI.h"
#import "TKOrderSummaryCell.h"

@interface DeliveryStatusViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TKOrderSummaryCell *sizingCell;

@property (strong, nonatomic) NSArray *orders;

@end

@implementation DeliveryStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"TKOrderSummaryCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TKOrderSummaryCell"];
    
    self.sizingCell = [cellNib instantiateWithOwner:nil options:nil].firstObject;
    
    BFTask *ordersTask = [[ParseAPI getInstance] ordersForToday];
    [ordersTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error while fetching ordersForToday: %@", task.error);
        } else {
            self.orders = task.result;
            NSLog(@"Calling reloadData");
            [self.tableView reloadData];
        }
        return nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TKOrderSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKOrderSummaryCell"];
    cell.order = self.orders[indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sizingCell.order = self.orders[indexPath.row];
    [self.sizingCell layoutIfNeeded];
    CGFloat height = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    NSLog(@"calculated height %f for cell at row %ld", height, (long) indexPath.row);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderStatusViewController *osvc = [[OrderStatusViewController alloc] init];
    osvc.order = self.orders[indexPath.row];
    osvc.reportLocationAsDriverLocation = YES;
    [self presentViewController:osvc animated:YES completion:nil];
}

@end
