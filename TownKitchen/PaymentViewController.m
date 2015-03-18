//
//  PaymentViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/17/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PaymentViewController.h"
#import "PTKView.h"
#import "STPCard.h"
#import "STPAPIClient.h"
#import "STPToken.h"
#import "Stripe.h"

@interface PaymentViewController () <PTKViewDelegate>

@property (weak, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.submitButton.enabled = NO;
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15, 20, 290, 55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    NSLog(@"Got payment with paymentView %@ and card %@", paymentView, card);
    self.submitButton.enabled = valid;
}

- (IBAction)onSubmit:(id)sender {
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    NSLog(@"Set up card: %@", card);
    NSLog(@"%@ %ld %ld %@", self.paymentView.card.number, self.paymentView.card.expMonth, self.paymentView.card.expYear, self.paymentView.card.cvc);

    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            NSLog(@"Error while handling card: %@", error);
        } else {
            [self createBackendChargeWithToken:token completion:nil];
        }
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void (^)(NSError *))completion {
    NSLog(@"Got the token: %@", token);
    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (completion != nil) {
                                   completion(error);
                               }
                           }];
}

@end
