//
//  IntroViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/24/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "IntroViewController.h"
#import "IntroSlideView.h"
#import <SwipeView/SwipeView.h>

@interface IntroViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) NSArray *introSlideData;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.swipeView.pagingEnabled = YES;
    [self.swipeView reloadData];
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
    return 4;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {

    IntroSlideView *slideView = [[IntroSlideView alloc] initWithFrame:self.swipeView.bounds];
    
    switch (index) {
        case 0:
        {
            slideView.image = [UIImage imageNamed:@"intro-slide-01"];
            slideView.text = @"The Town Kitchen:\nCommunity-Driven Lunch";
            break;
        }
        case 1:
        {
            slideView.image = [UIImage imageNamed:@"intro-slide-02"];
            slideView.text = @"We deliver chef-crafted,\nboxed lunch and employ\nlow-income youth.";
            break;
        }
        case 2:
        {
            slideView.image = [UIImage imageNamed:@"intro-slide-03"];
            slideView.text = @"We partner with local food artisans like Kika's Treats & Sugar Knife Sweets.";
            break;
        }
            case 3:
        {
            slideView.image = [UIImage imageNamed:@"intro-slide-04"];
            slideView.text = @"We believe that great food and great jobs create stronger communities.";
            break;
        }
        default:
            break;
    }

    return slideView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.pageControl.currentPage = swipeView.currentItemIndex;
}

@end
