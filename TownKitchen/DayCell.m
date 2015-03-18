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
#import "DateLabelsView.h"
#import "UIImageEffects.h"

@interface DayCell ()

@property (weak, nonatomic) IBOutlet DateLabelsView *dateLabelsView;

@property (readwrite, nonatomic) UIImage *originalImage;
@property (readwrite, nonatomic) UIImage *darkenedImage;
@property (readwrite, nonatomic) NSString *weekday;
@property (readwrite, nonatomic) NSString *monthAndDay;

@end

@implementation DayCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

}

#pragma mark - Custom Setters

- (void)setInventory:(Inventory *)inventory {
    _inventory = inventory;
    self.dateLabelsView.weekdayLabel.text = [DateUtils dayOfTheWeekFromDate:inventory.dateOffered];
    self.dateLabelsView.monthAndDayLabel.text = [DateUtils monthAndDayFromDate:inventory.dateOffered];
    self.weekday = self.dateLabelsView.weekdayLabel.text;
    self.monthAndDay = self.dateLabelsView.monthAndDayLabel.text;
    
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
                                                                     self.backgroundImageView.image = image;
                                                                     self.darkenedImage = self.backgroundImageView.image;
                                                                 } completion:^(BOOL finished) {
                                                                     self.originalImage = image;
                                                                 }];
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 NSLog(@"Error setting day view image: %@", error);
                                             }];
}

@end
