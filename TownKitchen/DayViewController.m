//
//  DayViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DayViewController.h"
#import "DayCell.h"

@interface DayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *days;

@end

@implementation DayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Town Kitchen";

    self.days = @[@{@"date": @"March 10", @"day": @"Tuesday"}, @{@"date": @"March 12", @"day": @"Thursday"}, @{@"date": @"March 16", @"day": @"Monday"}];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayCell" bundle:nil] forCellReuseIdentifier:@"DayCell"];
    self.tableView.rowHeight = self.tableView.frame.size.height / 3;
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.days.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayCell" forIndexPath:indexPath];
    cell.backgroundImageView.image = [UIImage imageNamed:@"egg-salad-salmon-overhead"];
    cell.dayLabel.text = self.days[indexPath.row][@"day"];
    cell.dateLabel.text = self.days[indexPath.row][@"date"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
