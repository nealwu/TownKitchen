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

@interface PaymentViewController () <PTKViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *sizingPaymentView;
@property (strong, nonatomic) PTKView *paymentView;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up payment view
    self.paymentView = [[PTKView alloc] initWithFrame:self.sizingPaymentView.frame];
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
}

#pragma mark PTKViewDelegate methods

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    NSLog(@"Got payment with paymentView %@ and card %@", paymentView, card);
}

@end
