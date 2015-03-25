//
//  LoginViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "DaySelectViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-logo"]];
    
    // Rounded corners
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    self.signupButton.layer.cornerRadius = 8;
    self.signupButton.clipsToBounds = YES;
}

- (IBAction)onLogin:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        if (user && !error) {
            NSLog(@"Login succeeded!");
            [self.delegate loginViewController:self didLoginUser:[PFUser currentUser]];
        } else {
            NSLog(@"Login failed: %@", error);
        }
    }];
}

- (IBAction)onSignup:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    PFUser *user = [PFUser user];
    user.username = email;
    user.email = email;
    user.password = password;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Signup succeeded!");
            [self.delegate loginViewController:self didLoginUser:[PFUser currentUser]];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Signup failed: %@", errorString);
        }
    }];
}

- (IBAction)onTapScreen:(id)sender {
    [self.emailTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn:");
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
    }
    return YES;
}

@end
