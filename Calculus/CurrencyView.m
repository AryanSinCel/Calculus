
#import "CurrencyView.h"
#import "ViewController.h"


@interface CurrencyView ()<UITextFieldDelegate>{
    NSString *selectTextField;
    NSString *from;
    NSString *to;
    NSString *curr;
    NSString *changingTextField;
}
@property (nonatomic,strong) NSMutableString *expressionString;
@property (nonatomic, strong) UITextField *currentEditingTextField;
@property (nonatomic) BOOL isTypingNumber;

@end

@implementation CurrencyView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for(UIButton *button in self.btns){
        button.layer.cornerRadius = 35;
        button.layer.borderWidth = 0.5;
    }
    
    if(self.isON){
        self.view.backgroundColor = [UIColor blackColor];
        self.label1.textColor = [UIColor whiteColor];
        self.label2.textColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.textField1.backgroundColor = [UIColor blackColor];
        self.textField1.textColor = [UIColor whiteColor];
        self.textField2.backgroundColor = [UIColor blackColor];
        self.textField2.textColor = [UIColor whiteColor];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.textField1.backgroundColor = [UIColor whiteColor];
        self.textField1.textColor = [UIColor blackColor];
        self.textField2.backgroundColor = [UIColor whiteColor];
        self.textField2.textColor = [UIColor blackColor];
    }
    
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    
    self.isTypingNumber = NO;
    self.label1.text = @"INR";
    self.label2.text = @"USD";
    self.expressionString = [NSMutableString stringWithString:@""];
    
    [self loadFlagImages];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentEditingTextField = textField;
    selectTextField = textField.placeholder;
    
    NSLog(@"Currently editing: %@", textField.placeholder);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentEditingTextField = nil;
    
    NSLog(@"Ended editing: %@", textField.placeholder);
}

- (void)loadFlagImages {
    NSURL *url1 = [NSURL URLWithString:@"https://www.xe.com/svgs/flags/inr.static.svg"];
    NSURL *url2 = [NSURL URLWithString:@"https://www.xe.com/svgs/flags/usd.static.svg"];
    
    [self.webView1 loadRequest:[NSURLRequest requestWithURL:url1]];
    
    [self.webView2 loadRequest:[NSURLRequest requestWithURL:url2]];
    
}



#pragma mark - Button Actions

- (IBAction)digitPressed:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
   
    if(tag >= 0 && tag <= 9){
        NSString *digit = [NSString stringWithFormat:@"%ld",(long)tag];
        if(self.isTypingNumber){
            if([selectTextField isEqualToString:@"textField1"]){
                self.textField1.text = [self.textField1.text stringByAppendingString:digit];
            }else{
                self.textField2.text = [self.textField2.text stringByAppendingString:digit];
            }
        }else{
            if([selectTextField isEqualToString:@"textField1"]){
                self.textField1.text = digit;
            }else{
                self.textField2.text = digit;
            }
            self.isTypingNumber = YES;
        }
    }else{
        switch (tag) {
            case 10:
                if([selectTextField isEqualToString:@"textField1"]){
                    self.textField1.text = [self.textField1.text stringByAppendingString:@"00"];
                }else{
                    self.textField2.text = [self.textField2.text stringByAppendingString:@"00"];
                }
                
                break;
            case 11:
                if([selectTextField isEqualToString:@"textField1"]){
                self.textField1.text = [self.textField1.text stringByAppendingString:@"."];
            }else{
                self.textField2.text = [self.textField2.text stringByAppendingString:@"."];
            }
                break;
            case 12:
                self.textField1.text = @"";
                self.textField2.text = @"";
                break;
            default:
                break;
        }
    }
    
}

- (IBAction)convertCurrency:(id)sender {

    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                               @"x-rapidapi-host": @"currency-convertor-api.p.rapidapi.com" };

    
    if(self.textField1.text.length > 0 && self.textField2.text.length == 0){
        from = self.label1.text;
        to = self.label2.text;
        curr = self.textField1.text;
        changingTextField = @"textField2";
    }
    else if(self.textField1.text.length == 0 && self.textField2.text.length > 0){
        from = self.label2.text;
        to = self.label1.text;
        curr = self.textField2.text;
        changingTextField = @"textField1";
    }else{
        from = self.label1.text;
        to = self.label2.text;
        curr = self.textField1.text;
        changingTextField = @"textField2";
    }
    
    
    NSString *url = [NSString stringWithFormat:@"https://currency-convertor-api.p.rapidapi.com/convert/%@/%@/%@",curr,from,to];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }

        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Parsing Error: %@", jsonError.localizedDescription);
            return;
        }

        NSLog(@"JSON Response: %@", json);

        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString *rate = json[@"rate"];
            if (rate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.textField2.text = rate;
                });
            } else {
                NSLog(@"'rate' key not found in response");
            }
        }
        else if ([json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArray = (NSArray *)json;
            NSLog(@"JSON is an array: %@", jsonArray);

            // Example: Access first item in array if applicable
            if (jsonArray.count > 0 && [jsonArray[0] isKindOfClass:[NSDictionary class]]) {
                NSString *rate = jsonArray[0][@"rate"];
                if (rate) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self->changingTextField isEqualToString:@"textField1"]){
                            self.textField1.text = rate;
                        }else{
                            self.textField2.text = rate;
                        }
                       
                    });
                }
            }
        } else {
            NSLog(@"Unexpected JSON structure");
        }
    }];
    [dataTask resume];
}

- (IBAction)button2:(id)sender {
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CountryView *view = [storyboard instantiateViewControllerWithIdentifier:@"CountryView"];
    view.selectedTextField = @"label2";
    view.delegate = self;
    view.isON = self.isON;
        [self presentViewController:view animated:YES completion:nil];
    
    
}

- (IBAction)button1:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CountryView *view = [storyboard instantiateViewControllerWithIdentifier:@"CountryView"];
    view.selectedTextField = @"label1";
    view.delegate = self;
    view.isON = self.isON;
        [self presentViewController:view animated:YES completion:nil];
    
    
}


-(void)sendData:(NSMutableDictionary *)string{
    if([[string valueForKey:@"label"]isEqualToString:@"label1"]){
        [self.webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[string valueForKey:@"flag"]]]];
        self.label1.text = [string valueForKey:@"currencyCode"];
        
    }else{
        [self.webView2 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[string valueForKey:@"flag"]]]];
        self.label2.text = [string valueForKey:@"currencyCode"];
    }
    
   
    NSLog(@"%@",string);
}


@end
