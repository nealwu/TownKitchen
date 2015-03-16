//
//  DayViewCell.m
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DayCell.h"
#import "DateUtils.h"
#import <UIImageView+AFNetworking.h>
#import <FXBlurView.h>

@interface DayCell ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (readwrite, nonatomic) UIImage *originalImage;

@end

@implementation DayCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundImageView.alpha = 0.5;
    }
    else {
        self.backgroundImageView.alpha = 1.0;
    }
}

#pragma mark - Custom Setters

- (void)setInventory:(Inventory *)inventory {
    _inventory = inventory;
    self.dayLabel.text = [DateUtils dayOfTheWeekFromDate:inventory.dateOffered];
    self.dateLabel.text = [DateUtils monthAndDayFromDate:inventory.dateOffered];
    
    NSURL *imageUrl = [[NSURL alloc] initWithString:inventory.menuOptionObject.imageURL];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageUrl];
    
    [self.backgroundImageView setImageWithURLRequest:imageRequest
                                    placeholderImage:[UIImage imageNamed:@"day-image-placeholder"]
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 nil;
                                                 
                                                 [UIView transitionWithView:self.backgroundImageView
                                                                   duration:0.3
                                                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                                                 animations:^{
                                                                     self.backgroundImageView.image = [image blurredImageWithRadius:20.0 iterations:10 tintColor:[UIColor blackColor]];
                                                                 } completion:^(BOOL finished) {
                                                                     self.originalImage = image;
                                                                 }];

                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 NSLog(@"Error setting day view image: %@", error);
                                             }];
}

@end
