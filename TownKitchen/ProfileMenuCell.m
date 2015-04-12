//
//  ProfileMenuCell.m
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ProfileMenuCell.h"

@interface ProfileMenuCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ProfileMenuCell

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
