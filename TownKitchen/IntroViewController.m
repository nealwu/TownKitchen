//
//  IntroViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/24/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "IntroViewController.h"
#import <SwipeView/SwipeView.h>

@interface IntroViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.swipeView.pagingEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.swipeView.delegate = nil;
    self.swipeView.dataSource = nil;
}


#pragma mark SwipeView Methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 3;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    return [UIView new];
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return self.swipeView.bounds.size;
}

@end
