//
//  ProfileViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileViewController;

@protocol ProfileViewControllerDelegate <NSObject>

- (void)profileViewControllerDidLogout:(ProfileViewController *)pvc;

@end

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) id<ProfileViewControllerDelegate> delegate;

@end
