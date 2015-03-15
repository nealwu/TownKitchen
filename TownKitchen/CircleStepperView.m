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
@property (strong, nonatomic) UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@end

@implementation CircleStepperView

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
    UINib *nib = [UINib nibWithNibName:@"CircleStepperView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    self.stepper = [[UIStepper alloc] init];
    self.stepper.maximumValue = 99;
    self.stepper.minimumValue = 0;
    [self.stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (!self.value) {
        self.value = 0;
    }
}

- (void)setValue:(int)value {
    _value = value;
    self.stepper.value = 0;
    self.quantityLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
}

- (void)stepperValueChanged:(UIStepper *)stepper {
    NSLog(@"value is now: %f", stepper.value);
    self.quantityLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
    [self.delegate circleStepperView:self didUpdateValue:(int)stepper.value];
}

#pragma mark - Actions
- (IBAction)onMinusButton:(id)sender {
    self.stepper.value --;
    [self stepperValueChanged:self.stepper];
}

- (IBAction)onPlusButton:(id)sender {
    self.stepper.value ++;
    [self stepperValueChanged:self.stepper];
}

@end
