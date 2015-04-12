//
//  ProfileViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ProfileViewController.h"

#import "TKHeader.h"
#import "ParseAPI.h"
#import "ProfileLogoutCell.h"
#import "ProfileMenuCell.h"
#import "UIColor+TKColorPalette.h"

typedef NS_ENUM(NSInteger, TableViewSection) {
    TableViewSectionYourAccount = 0,
    TableViewSectionAchievements = 1,
};

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, ProfileLogoutCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TKHeader *header;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TableViewSectionYourAccount:
            return @"Your Account";
        case TableViewSectionAchievements:
            return @"Achievements";
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TableViewSectionYourAccount:
            return 40;
        case TableViewSectionAchievements:
            return 30;
        default:
            return 30;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TableViewSectionYourAccount:
            return 4;
        case TableViewSectionAchievements:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == TableViewSectionYourAccount) {
        ProfileMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileMenuCell"];
        NSArray *accountMenuOptions = @[@"Profile", @"Credit Cards", @"Addresses", @"Enter Code"];
        cell.title = accountMenuOptions[indexPath.row];
        return cell;
        
    } else if (indexPath.section == TableViewSectionAchievements) {
        ProfileMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileMenuCell"];
        if (indexPath.row < 2) {
            NSArray *achievementsMenuOptions = @[@"Who You've Helped", @"Community Leaderboard"];
            cell.title = achievementsMenuOptions[indexPath.row];
            return cell;
            
        } else if (indexPath.row == 2) {
            ProfileLogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileLogoutCell"];
            cell.delegate = self;
            return cell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ProfileLogoutCellDelegate

- (void)profileLogoutCellDidTapLogout:(ProfileLogoutCell *)cell {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate profileViewControllerDidLogout:self];
    }];
}

#pragma mark - Private Methods

- (void)onExit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setup {
    // Create cancel button
    CGRect cancelButtonFrame = self.header.leftView.bounds;
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    [self.cancelButton addTarget:self action:@selector(onExit) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel-button"] forState:UIControlStateNormal];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel-button-highlighted"] forState:UIControlStateHighlighted];
    [self.header.leftView addSubview:self.cancelButton];
    
    // Add title
    CGRect titleLabelFrame = self.header.titleView.bounds;
    titleLabelFrame.origin.y -= 2;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    titleLabel.text = [[PFUser currentUser] username];
    titleLabel.font = [UIFont fontWithName:@"Futura" size:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.header.titleView addSubview:titleLabel];
    
    // set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileMenuCell" bundle:nil] forCellReuseIdentifier:@"ProfileMenuCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileLogoutCell" bundle:nil] forCellReuseIdentifier:@"ProfileLogoutCell"];
    
}

@end
