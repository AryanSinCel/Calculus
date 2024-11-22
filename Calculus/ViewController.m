#import "ViewController.h"
#import <math.h>
#import "CurrencyView.h"


@interface ViewController () {
    BOOL isSideViewOpen;
}
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (nonatomic, strong) NSMutableString *expressionString;
@property (nonatomic) BOOL isTypingNumber;
@property (nonatomic, strong) NSMutableArray *history;
@end

@implementation ViewController
@synthesize sideBar, sideView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIButton *button in self.btns) {
           button.layer.cornerRadius = 35;
        button.layer.borderWidth = 0.5;
       }
    NSLog(@"%@",self.btns);
    
    self.isTypingNumber = NO;
    self.expressionString = [NSMutableString stringWithString:@""];
    self.displayLabel.text = @"0";
    
    sideBar.backgroundColor = [UIColor systemGroupedBackgroundColor];
    sideBar.hidden = YES;
    sideView.hidden = YES;
    isSideViewOpen = NO;
    
    self.history = [NSMutableArray array];
    self.history = [self loadHistory];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.history[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.history removeObjectAtIndex:indexPath.row];
        [self saveHistory];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.displayLabel.text = self.history[indexPath.row];
}


- (IBAction)digitPressed:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSString *exp = self.displayLabel.text;
    
    
    if (tag >= 0 && tag <= 9) {
        NSString *digit = [NSString stringWithFormat:@"%ld", (long)tag];
        
        if (self.isTypingNumber) {
            self.displayLabel.text = [self.displayLabel.text stringByAppendingString:digit];
        } else {
            self.displayLabel.text = digit;
            self.isTypingNumber = YES;
        }
    } else {
        switch (tag) {
            case 10: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"+"]; break;
            case 11: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"-"]; break;
            case 12: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"*"]; break;
            case 13: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"/"]; break;
            case 14: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"^"]; break;
            case 15: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"."]; break;
            case 16: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"("]; break;
            case 17: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@")"]; break;
            case 18: if(exp.length > 0){
                    self.displayLabel.text = [exp substringToIndex:[exp length]-1];break;
                }
            case 19: self.displayLabel.text = [self.displayLabel.text stringByAppendingString:@"%"]; break;
            default: break;
        }
    }
}

- (IBAction)equalPressed:(UIButton *)sender {
    NSString *expression = self.displayLabel.text;
    
    NSArray *postfix = [self infixToPostfix:expression];
    double result = [self evaluatePostfix:postfix];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 6;
    formatter.minimumFractionDigits = 0;
    
    NSString *resultString;
    if (result == (int)result) {
        resultString = [NSString stringWithFormat:@"%d", (int)result];
    } else {
        resultString = [formatter stringFromNumber:@(result)];
    }
    
    self.displayLabel.text = resultString;
    [self.history addObject:[NSString stringWithFormat:@"%@ = %@", expression, resultString]];
    [self saveHistory];
}

- (IBAction)clearPressed:(UIButton *)sender {
    self.displayLabel.text = @"0";
    [self.expressionString setString:@""];
    self.isTypingNumber = NO;
}

- (NSArray *)infixToPostfix:(NSString *)expression {
    NSMutableArray *tokens = [self tokenizeExpression:expression];
    NSMutableArray *output = [NSMutableArray array];
    NSMutableArray *stack = [NSMutableArray array];
    
    for (NSString *token in tokens) {
        if ([self isNumber:token]) {
            [output addObject:token];
        } else if ([token isEqualToString:@"("]) {
            [stack addObject:token];
        } else if ([token isEqualToString:@")"]) {
            while (![stack.lastObject isEqualToString:@"("]) {
                [output addObject:stack.lastObject];
                [stack removeLastObject];
            }
            [stack removeLastObject];
        } else {
            while (stack.count > 0 && [self precedenceForOperator:stack.lastObject] >= [self precedenceForOperator:token]) {
                [output addObject:stack.lastObject];
                [stack removeLastObject];
            }
            [stack addObject:token];
        }
    }
    
    while (stack.count > 0) {
        [output addObject:stack.lastObject];
        [stack removeLastObject];
    }
    
    return output;
}

- (NSMutableArray *)tokenizeExpression:(NSString *)expression {
    NSMutableArray *tokens = [NSMutableArray array];
    NSCharacterSet *operators = [NSCharacterSet characterSetWithCharactersInString:@"+-*/%^()"];
    NSUInteger length = [expression length];
    
    for (NSUInteger i = 0; i < length; i++) {
        unichar c = [expression characterAtIndex:i];
        
        if ([operators characterIsMember:c]) {
            [tokens addObject:[NSString stringWithFormat:@"%c", c]];
        } else if (isdigit(c) || c == '.') {
            NSMutableString *number = [NSMutableString string];
            while (i < length && (isdigit([expression characterAtIndex:i]) || [expression characterAtIndex:i] == '.')) {
                [number appendFormat:@"%c", [expression characterAtIndex:i]];
                i++;
            }
            [tokens addObject:number];
            i--;
        }
    }
    return tokens;
}

- (BOOL)isNumber:(NSString *)str {
    NSCharacterSet *decimalSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    return [str rangeOfCharacterFromSet:[decimalSet invertedSet]].location == NSNotFound;
}

- (NSInteger)precedenceForOperator:(NSString *)operator {
    NSDictionary *precedence = @{@"^": @3, @"*": @2, @"/": @2, @"%": @2, @"+": @1, @"-": @1};
    return [precedence[operator] integerValue];
}

- (double)evaluatePostfix:(NSArray *)postfix {
    NSMutableArray *stack = [NSMutableArray array];
    
    for (NSString *token in postfix) {
        if ([self isNumber:token]) {
            [stack addObject:@([token doubleValue])];
        } else {
            double b = [[stack lastObject] doubleValue];
            [stack removeLastObject];
            double a = [[stack lastObject] doubleValue];
            [stack removeLastObject];
            double result = 0;
            
            if ([token isEqualToString:@"+"]) result = a + b;
            else if ([token isEqualToString:@"-"]) result = a - b;
            else if ([token isEqualToString:@"*"]) result = a * b;
            else if ([token isEqualToString:@"/"]) result = a / b;
            else if ([token isEqualToString:@"%"]) result = (int)a % (int)b;
            else if ([token isEqualToString:@"^"]) result = pow(a, b);
            
            [stack addObject:@(result)];
        }
    }
    return [[stack lastObject] doubleValue];
}

- (IBAction)historyBtn:(id)sender {
    if (isSideViewOpen) {
           // Close side view
           [UIView animateWithDuration:0.2 animations:^{
               self->sideView.frame = CGRectMake(377,146,0,632);
               self->sideBar.frame = CGRectMake(361,0,0,632);
           } completion:^(BOOL finished) {
               self->sideView.hidden = YES;
               self->sideBar.hidden = YES;
           }];
       } else {
           // Open side view
           sideView.hidden = NO;
           sideBar.hidden = NO;
           [self.view bringSubviewToFront:sideView];
           [UIView animateWithDuration:0.2 animations:^{
               self->sideView.frame = CGRectMake(16,146,361,632);
               self->sideBar.frame = CGRectMake(0,0,361,632);
           }];
       }
       isSideViewOpen = !isSideViewOpen;
   }


- (void)saveHistory {
    [[NSUserDefaults standardUserDefaults] setObject:self.history forKey:@"history"];
    [[NSUserDefaults standardUserDefaults] synchronize]; // Synchronize changes to save permanently
}


- (NSMutableArray *)loadHistory {
    NSArray *savedHistory = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    return savedHistory ? [savedHistory mutableCopy] : [NSMutableArray array]; // Return an empty array if no tasks are saved
}

- (IBAction)switch:(id)sender {
    
    if(self.switchBtn.isOn){
        NSLog(@"switch is ON");
        self.view.backgroundColor = [UIColor blackColor];
        self.sideView.backgroundColor = [UIColor blackColor];
        self.sideBar.backgroundColor = [UIColor clearColor];
        self.historyBtn.tintColor = [UIColor whiteColor];
        self.currencyBtn.tintColor = [UIColor whiteColor];
        self.displayLabel.backgroundColor = [UIColor blackColor];
        self.displayLabel.textColor = [UIColor whiteColor];
    }else{
        NSLog(@"switch is OFF");
        self.view.backgroundColor = [UIColor whiteColor];
        self.sideView.backgroundColor = [UIColor whiteColor];
        self.sideBar.backgroundColor = [UIColor clearColor];
        self.historyBtn.tintColor = [UIColor blackColor];
        self.currencyBtn.tintColor = [UIColor blackColor];
        self.displayLabel.backgroundColor = [UIColor whiteColor];
        self.displayLabel.textColor = [UIColor blackColor];
    }
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showCurrencyConvertor"]){
        CurrencyView *view = [segue destinationViewController];
        if(self.switchBtn.isOn){
            view.isON = YES;
        }else{
            view.isON = NO;
        }
    }
    
    
}
@end
