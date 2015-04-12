//
//  ProfileLogoutCell.m
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ProfileLogoutCell.h"

@implementation ProfileLogoutCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onLogout:(id)sender {
    [self.delegate profileLogoutCellDidTapLogout:self];
}

@end
