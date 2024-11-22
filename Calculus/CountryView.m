//
//  CountryView.m
//  Calculus
//
//  Created by Celestial on 20/11/24.
//

#import "CountryView.h"
#import "CountryCell.h"
#import "CurrencyView.h"

@interface CountryView ()
@property (nonatomic,strong) NSMutableArray *country;
@end

@implementation CountryView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isON){
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    
    if([self loadCountry].count == 0){
        [self getCountry];
    }else{
        self.country = [self loadCountry];
        NSLog(@"Country : %@",self.country);
    }
    
    if(self.selectedTextField){
        NSLog(@"%@",self.selectedTextField);
    }
   
}

-(void)getCountry{
    
    NSDictionary *headers = @{ @"x-rapidapi-key": @"800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
                               @"x-rapidapi-host": @"currency-convertor-api.p.rapidapi.com" };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://currency-convertor-api.p.rapidapi.com/currency"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    }
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(jsonError){
            NSLog(@"Json Error : %@",jsonError.localizedDescription);
        }
        self.country = [json mutableCopy];
        NSLog(@"Json : %@",self.country);
        [[NSUserDefaults standardUserDefaults] setObject:self.country forKey:@"country"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
                                                }];
    [dataTask resume];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.country.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CountryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *svgUrl = [[self.country objectAtIndex:indexPath.row]valueForKey:@"flag"];
    [cell.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:svgUrl]]];
    cell.countryLabel.text = [[self.country objectAtIndex:indexPath.row] valueForKey:@"currencyName"];
    cell.countryCodeLabel.text = [[self.country objectAtIndex:indexPath.row]valueForKey:@"currencyCode"];
    
    if(self.isON){
        cell.backgroundColor = [UIColor blackColor];
        cell.countryLabel.textColor = [UIColor whiteColor];
        cell.countryCodeLabel.textColor = [UIColor whiteColor];
    }
    
//    cell.layer.borderWidth = 10;
//    cell.backgroundColor = [UIColor blackColor];
//    cell.countryLabel.textColor = [UIColor whiteColor];
//    cell.countryCodeLabel.textColor = [UIColor whiteColor];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;  // Set row height with some extra space (for example, 80px)
}



- (NSMutableArray *)loadCountry {
    NSArray *savedCountry = [[NSUserDefaults standardUserDefaults] objectForKey:@"country"];
    return savedCountry ? [savedCountry mutableCopy] : [NSMutableArray array];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSMutableDictionary *dic = [[self.country objectAtIndex:indexPath.row]mutableCopy];
    [dic setValue:self.selectedTextField forKey:@"label"];
    
    [self.delegate sendData:dic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
