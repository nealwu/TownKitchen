//
//  AppDelegate.m
//  TownKitchen
//
//  Created by Peter Bai on 3/4/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "AppDelegate.h"
#import <Bolts.h>
#import "DaySelectViewController.h"
#import "IntroViewController.h"
#import "LoginViewController.h"
#import "Order.h"
#import "OrderCell.h"
#import "OrderCreationViewController.h"
#import "OrderStatusViewController.h"
#import "OrdersViewController.h"
#import <Parse/Parse.h>
#import "ReviewViewController.h"
#import "Stripe.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"GzDzQtpaJvTQhot8t8sTghxRQX5THinfgZ0LuGZa" clientKey:@"x0vME3m9CR0F7QXcV23uqHPKOX4LyInfe8aV7JKK"];
    [Stripe setDefaultPublishableKey:@"pk_test_XABTD877BYdT5GEGUNvUL5W7"];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidChange:) name:@"TKCurrentUserDidChange" object:nil];

    // Show intro if first time launching app
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        IntroViewController *introViewController = [[IntroViewController alloc] init];
        self.window.rootViewController = introViewController;
    } else if ([PFUser currentUser]) {
        // If logged in, go directly to day select VC
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TKCurrentUserDidChange" object:self];
        DaySelectViewController *daySelectViewController = [[DaySelectViewController alloc] init];
        self.window.rootViewController = daySelectViewController;
    } else {
        // Otherwise, go to login screen
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        self.window.rootViewController = loginViewController;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)onUserDidChange:(NSNotification *)notification {
    PFInstallation *installation = [PFInstallation currentInstallation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        installation.channels = @[ @"global", user.objectId ];
    } else {
        installation.channels = @[ @"global" ];
    }
    [installation saveInBackground];
}

- (void)registerForNotifications {
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    UIApplication *application = [UIApplication sharedApplication];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];
    [installation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Got remote notification: %@", userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TKDidReceiveNotification" object:self];
}

@end
