//
//  DebugSelectorViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DebugSelectorViewController.h"
#import "OrderCreationViewController.h"
#import "CheckoutViewController.h"

@interface DebugSelectorViewController ()

@end

@implementation DebugSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)onOrderCreationViewController:(id)sender {
    [self.navigationController pushViewController:[[OrderCreationViewController alloc] init] animated:YES];
}
- (IBAction)onCheckoutViewController:(id)sender {
    [self.navigationController pushViewController:[[CheckoutViewController alloc] init] animated:YES];
}

@end
