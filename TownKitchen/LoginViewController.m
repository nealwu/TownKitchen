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
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tripleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapGesture;

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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TKCurrentUserDidChange" object:self];
            if (self.delegate) {
                [self.delegate loginViewController:self didLoginUser:[PFUser currentUser]];
            } else {
                [self goToDaySelectVC];
            }
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Login failed: %@", errorString);

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid email or password" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TKCurrentUserDidChange" object:self];
            if (self.delegate) {
                [self.delegate loginViewController:self didLoginUser:[PFUser currentUser]];
            } else {
                [self goToDaySelectVC];
            }
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Signup failed: %@", errorString);

            errorString = [errorString stringByReplacingOccurrencesOfString:@"username" withString:@"email"];
            NSString *capitalizedError = [errorString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[errorString substringToIndex:1] capitalizedString]];

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:capitalizedError message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark - Actions

- (IBAction)onTapScreen:(id)sender {
    [self.emailTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}

- (IBAction)onTripleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"detected triple tap");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenIntro"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn:");
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self onLogin:self];
    }
    return YES;
}

#pragma mark - Private Methods

- (void)goToDaySelectVC {
    DaySelectViewController *daySelectViewController = [[DaySelectViewController alloc] init];
    [self presentViewController:daySelectViewController animated:YES completion:nil];
}

@end
