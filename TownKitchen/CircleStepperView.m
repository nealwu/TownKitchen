//
//  CircleStepperView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CircleStepperView.h"

@interface CircleStepperView()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation CircleStepperView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initwithcoder called");
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initwithframe called");
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    UINib *nib = [UINib nibWithNibName:@"CircleStepperView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    NSLog(@"self.contentView.frame: %@, self.bounds: %@", NSStringFromCGRect(self.contentView.frame), NSStringFromCGRect(self.bounds));
}
- (IBAction)onButton:(id)sender {
    
    NSLog(@"button pressed!");
}

@end
