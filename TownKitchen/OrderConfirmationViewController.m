//
//  OrderConfirmationViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderConfirmationViewController.h"

@interface OrderConfirmationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation OrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews {
    self.view.layer.cornerRadius = 8.0;
    
    self.emailLabel.text = self.email;
    
    // create shadow
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 3;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.view.layer.shadowOpacity = 0.1f;
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.view.layer.shouldRasterize = YES;
}

- (void)setEmail:(NSString *)email {
    _email = email;
    self.emailLabel.text = email;
}

- (IBAction)onDoneButton:(UIButton *)sender {
    NSLog(@"done button pressed");
}

@end
