//
//  IntroSlideView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/24/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "IntroSlideView.h"

@interface IntroSlideView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation IntroSlideView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    // Load nib
    UINib *nib = [UINib nibWithNibName:@"CheckoutView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

@end
