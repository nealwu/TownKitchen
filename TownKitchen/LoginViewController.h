//
//  LoginViewController.h
//  TownKitchen
//
//  Created by Neal Wu on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)loginViewController didLoginUser:(PFUser *)user;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end
