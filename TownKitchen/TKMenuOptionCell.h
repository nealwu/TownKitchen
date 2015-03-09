//
//  TKMenuOptionCell.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuOption.h"

@interface TKMenuOptionCell : UITableViewCell

@property (nonatomic) NSInteger quantity;
@property (strong, nonatomic) MenuOption *menuOption;

@end
