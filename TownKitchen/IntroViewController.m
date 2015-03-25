//
//  IntroViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/24/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "IntroViewController.h"
#import "IntroSlideView.h"
#import "LoginViewController.h"
#import <UIView+MTAnimation.h>
#import <SwipeView/SwipeView.h>

@interface IntroViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) NSArray *introSlideData;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (assign, nonatomic) BOOL hasAnimatedOntoScreen;

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

- (void)viewWillLayoutSubviews {
    if (!self.hasAnimatedOntoScreen) {
        [self animateOntoScreen];
        self.hasAnimatedOntoScreen = YES;
    }
}

#pragma mark - Private Methods

- (void)animateOntoScreen {
    CGRect finalFrame = self.swipeView.frame;
    CGRect initialFrame = finalFrame;
    initialFrame.origin.x += initialFrame.size.width;
    
    self.swipeView.frame = initialFrame;
    
    [UIView mt_animateWithViews:@[self.swipeView]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseInOutCubic
                     animations:^{
                         self.swipeView.frame = finalFrame;
                     } completion:^{
                         nil;
                     }];
}

- (void)transitionToNextVC {
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark - SwipeView Methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 5;
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
        case 4:
        {
            return [UIView new];
        }
        default:
            break;
    }

    return slideView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.pageControl.currentPage = swipeView.currentItemIndex;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    if (swipeView.currentItemIndex == 4) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenIntro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self transitionToNextVC];
    }
}

#pragma mark - Private Methods

- (IBAction)onPageControlChanged:(UIPageControl *)pageControl {
    [self.swipeView scrollToItemAtIndex:pageControl.currentPage duration:0.5];
}

@end
