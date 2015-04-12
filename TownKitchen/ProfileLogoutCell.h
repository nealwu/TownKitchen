//
//  ProfileLogoutCell.h
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileLogoutCell;

@protocol ProfileLogoutCellDelegate <NSObject>

- (void)profileLogoutCellDidTapLogout:(ProfileLogoutCell *)cell;

@end

@interface ProfileLogoutCell : UITableViewCell

@property (weak, nonatomic) id<ProfileLogoutCellDelegate> delegate;

@end
