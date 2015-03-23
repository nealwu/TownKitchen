//
//  OrderStatusDetailView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderStatusDetailView.h"
#import "OrderStatusDetailViewCell.h"
#import "MenuOption.h"

@interface OrderStatusDetailView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToMenuOptionObject;

@end

@implementation OrderStatusDetailView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    // Load nib
    UINib *nib = [UINib nibWithNibName:@"OrderStatusDetailView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    // set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderStatusDetailViewCell" bundle:nil] forCellReuseIdentifier:@"OrderStatusDetailViewCell"];
    [self.tableView reloadData];
}

#pragma mark - Custom setters

- (void)setOrder:(Order *)order {
    _order = order;
    self.shortNameToMenuOptionObject = [order shortNameToMenuOptionObject];
    
    // populate self.menuOptionShortNames
    NSMutableArray *mutableMenuOptionShortnames = [NSMutableArray array];
    for (NSString *shortName in order.items) {
        if ([order.items[shortName] isEqualToNumber:@0]) {
            continue;
        }
        else {
            [mutableMenuOptionShortnames addObject:shortName];
        }
    }
    self.menuOptionShortNames = [NSArray arrayWithArray:mutableMenuOptionShortnames];
    [self.tableView reloadData];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shortNameToMenuOptionObject.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderStatusDetailViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderStatusDetailViewCell"];
    
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    MenuOption *menuOption = self.shortNameToMenuOptionObject[shortName];
    float quantity = [self.order.items[shortName] floatValue];
    
    cell.quantity = [NSNumber numberWithFloat:quantity];
    cell.itemDescription = menuOption.mealDescription;
    cell.imageUrl = menuOption.imageURL;
    
    return cell;
}

@end
