//
//  AddressInputViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "AddressInputViewController.h"

@interface AddressInputViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddressInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

#pragma mark Private Methods

- (void)setup {
    // Set up search bar
    self.searchBar.delegate = self;
    self.searchBar.text = self.initialSearchTerm;
    [self.searchBar becomeFirstResponder];
    
    // Set up navigation bar
    self.navigationItem.titleView = self.searchBar;
    
    // Set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark UISearchBarDelegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
