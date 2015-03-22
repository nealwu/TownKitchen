//
//  TKHeader.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TKHeader.h"

@interface TKHeader ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation TKHeader

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
    UINib *nib = [UINib nibWithNibName:@"TKHeader" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0,1);
    CGRect shadowPath = CGRectMake(self.layer.bounds.origin.x - 10, self.layer.bounds.size.height - 6, self.layer.bounds.size.width + 20, 5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    self.layer.shouldRasterize = YES;
}

@end
