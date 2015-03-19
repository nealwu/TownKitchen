//
//  PaymentViewController.m
//  
//
//  Created by Peter Bai on 3/19/15.
//
//

#import "PaymentViewController.h"
#import "PTKView.h"
#import "STPCard.h"
#import "STPAPIClient.h"
#import "TKNavigationBar.h"

@interface PaymentViewController () <PTKViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *sizingPaymentView;
@property (strong, nonatomic) PTKView *paymentView;
@property (strong, nonatomic) TKNavigationBar *navigationBar;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar = [[TKNavigationBar alloc] init];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    // Create cancel button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    
    navItem.leftBarButtonItem = cancelButtonItem;
    
    [self.navigationBar setItems:@[navItem]];
    [self.view addSubview:self.navigationBar];
    
    
    self.paymentView = [[PTKView alloc] init];
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
//    NSLog(@"sizing view frame: %@", NSStringFromCGRect(self.sizingPaymentView.frame));
//    NSLog(@"self view frame: %@", NSStringFromCGRect(self.view.frame));
}

- (void)viewDidLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // set navigation bar frame
    self.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64.0);

    // set up payment view
    self.paymentView.frame = self.sizingPaymentView.frame;
    
//    NSLog(@"sizing view frame: %@", NSStringFromCGRect(self.sizingPaymentView.frame));
//    NSLog(@"self view frame: %@", NSStringFromCGRect(self.view.frame));
};

#pragma mark PTKViewDelegate methods

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    NSLog(@"Got payment with paymentView %@ and card %@", paymentView, card);
}

#pragma mark Private Methods

- (void)onCancel {
    [self.paymentView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
