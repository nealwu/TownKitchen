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
#import "OrderCreationViewController.h"
#import "DaySelectViewController.h"

#import "ReviewViewController.h"
#import "DebugSelectorViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"GzDzQtpaJvTQhot8t8sTghxRQX5THinfgZ0LuGZa" clientKey:@"x0vME3m9CR0F7QXcV23uqHPKOX4LyInfe8aV7JKK"];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    OrderStatusViewController *osvc =[[OrderStatusViewController alloc] init];
    PFQuery *query = [Order query];
    [[[query getFirstObjectInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        Order *order = task.result;
        return [[order fetchMenuOptions] continueWithSuccessBlock:^id(BFTask *task) {
            return order;
        }];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        osvc.order = task.result;
        return nil;
    }];
//    DaySelectViewController *dvc = [[DaySelectViewController alloc] init];
//    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dvc];
    
    DebugSelectorViewController *dsvc = [[DebugSelectorViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dsvc];
    
//    self.window.rootViewController = osvc;
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
