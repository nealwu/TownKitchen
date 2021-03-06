//
//  ReviewLabelsView.m
//  TownKitchen
//
//  Created by Peter Bai on 4/3/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ReviewLabelsView.h"

@interface ReviewLabelsView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ReviewLabelsView

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
    UINib *nib = [UINib nibWithNibName:@"ReviewLabelsView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

@end
