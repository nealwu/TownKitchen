//
//  AppDelegate.m
//  TownKitchen
//
//  Created by Peter Bai on 3/4/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "AppDelegate.h"
#import <Bolts.h>
#import "OrderStatusViewController.h"
#import "Order.h"
#import <Parse/Parse.h>
#import "Stripe.h"
#import "OrderCreationViewController.h"
#import "DaySelectViewController.h"

#import "ReviewViewController.h"
#import "OrderCell.h"
#import "OrdersViewController.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

NSString * const STRIPE_PUBLISHABLE_KEY = @"pk_test_XABTD877BYdT5GEGUNvUL5W7";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"GzDzQtpaJvTQhot8t8sTghxRQX5THinfgZ0LuGZa" clientKey:@"x0vME3m9CR0F7QXcV23uqHPKOX4LyInfe8aV7JKK"];
    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

//    OrderStatusViewController *osvc =[[OrderStatusViewController alloc] init];
//    PFQuery *query = [Order query];
//    [[[query getFirstObjectInBackground] continueWithSuccessBlock:^id(BFTask *task) {
//        Order *order = task.result;
//        return [[order fetchMenuOptions] continueWithSuccessBlock:^id(BFTask *task) {
//            return order;
//        }];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        osvc.order = task.result;
//        return nil;
//    }];
//
//    self.window.rootViewController = osvc;

//    DaySelectViewController *dsvc = [[DaySelectViewController alloc] init];
    LoginViewController *lvc = [[LoginViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:lvc];
    nvc.navigationBar.translucent = NO;
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:235.0 / 255
                                                     green:92.0 / 255
                                                      blue:87.0 / 255
                                                     alpha:1.0];
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
