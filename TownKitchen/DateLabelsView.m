//
//  DateLabelsView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/16/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DateLabelsView.h"

@interface DateLabelsView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation DateLabelsView

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
    UINib *nib = [UINib nibWithNibName:@"DateLabelsView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

#pragma mark - Private Methods

- (void)shrinkToHeaderSizeWithAnimation:(BOOL)animated {

}

- (void)returnToNormalSizeWithAnimation:(BOOL)animated {
    
}



@end
