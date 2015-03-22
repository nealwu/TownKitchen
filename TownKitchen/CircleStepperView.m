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
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *plusButtonPushBehavior;

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
    
    // register for notifications to bounce plus button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bouncePlusButton:)
                                                 name:@"BouncePlusButton"
                                               object:nil];
}

- (void)setValue:(int)value {
    _value = value;
    self.stepper.value = value;
    self.quantityLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
}

- (void)stepperValueChanged:(UIStepper *)stepper {
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

#pragma mark - Private Methods

- (void)bouncePlusButton:(NSNotification *)notification {
    if (![[notification name] isEqualToString:@"BouncePlusButton"]) {
        return;
    }
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.contentView];
    
    CGFloat bottomInset = self.bounds.size.height / 2 - self.plusButton.bounds.size.height / 2;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.plusButton]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-200, 0, bottomInset, 0)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.plusButton]];
    [self.animator addBehavior:self.gravityBehavior];
    
    self.plusButtonPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.plusButton] mode:UIPushBehaviorModeInstantaneous];
    self.plusButtonPushBehavior.magnitude = 0.0f;
    self.plusButtonPushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.plusButtonPushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.plusButton]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
    
    self.plusButtonPushBehavior.pushDirection = CGVectorMake(0.0f, 0.5f);
    self.plusButtonPushBehavior.active = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
