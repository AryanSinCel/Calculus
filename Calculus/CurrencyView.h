//
//  CurrencyView.h
//  Calculus
//
//  Created by Celestial on 18/11/24.
//

#import <UIKit/UIKit.h>
#import "CountryView.h"

NS_ASSUME_NONNULL_BEGIN


@interface CurrencyView : UIViewController<CurrencyDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView1;
@property (weak, nonatomic) IBOutlet UIWebView *webView2;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;

- (IBAction)button1:(id)sender;
- (IBAction)button2:(id)sender;


- (IBAction)convertCurrency:(id)sender;
- (IBAction)digitPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (nonatomic) BOOL isON;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;



@end

NS_ASSUME_NONNULL_END
