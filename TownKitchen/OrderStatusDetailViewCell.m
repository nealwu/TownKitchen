//
//  OrderStatusDetailViewCell.m
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderStatusDetailViewCell.h"
#import <UIImageView+AFNetworking.h>

@interface OrderStatusDetailViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuOptionImage;

@end

@implementation OrderStatusDetailViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Custom Setters

- (void)setItemDescription:(NSString *)itemDescription {
    _itemDescription = itemDescription;
    self.nameLabel.text = itemDescription;
}

- (void)setQuantity:(NSNumber *)quantity {
    _quantity = quantity;
    
    if ([quantity doubleValue] > 0) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%.0f", [quantity floatValue]];
    } else {
        self.quantityLabel.text = @"";
    }
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    
    NSURL *thisImageUrl = [[NSURL alloc] initWithString:imageUrl];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:thisImageUrl];
    
    [self.menuOptionImage setImageWithURLRequest:imageRequest
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             [UIView transitionWithView:self.menuOptionImage
                                                               duration:0.3
                                                                options:UIViewAnimationOptionTransitionCrossDissolve
                                                             animations:^{
                                                                 self.menuOptionImage.image = image;
                                                             } completion:^(BOOL finished) {
                                                                 nil;
                                                             }];
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             NSLog(@"Error setting order creation view image: %@", error);
                                         }];
}

@end
