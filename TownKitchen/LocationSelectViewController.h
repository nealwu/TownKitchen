//
//  LocationSelectViewController.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationSelectViewController;

@protocol LocationSelectViewControllerDelegate

- (void)locationSelectViewController:(LocationSelectViewController *)locationSelectViewController didSelectAddress:(NSString *)address;

@end

@interface LocationSelectViewController : UIViewController

@property (weak, nonatomic) id<LocationSelectViewControllerDelegate> delegate;

@end
