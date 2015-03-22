//
//  AddressInputViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class AddressInputViewController, GKPlaceDetails;

@protocol AddressInputViewControllerDelegate <NSObject>

- (void)addressInputViewController:(AddressInputViewController *)addressInputViewController didSelectPlaceDetails:(GKPlaceDetails *)details;
- (void)addressInputViewController:(AddressInputViewController *)addressInputViewController shouldDismissAddressInputNavigationController:(UINavigationController *)navigationController;

@end

@interface AddressInputViewController : UIViewController

@property (nonatomic, strong) NSString *initialSearchTerm;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, weak) id<AddressInputViewControllerDelegate> delegate;

@end
