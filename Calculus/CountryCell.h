//
//  CountryCell.h
//  Calculus
//
//  Created by Celestial on 20/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;


@end

NS_ASSUME_NONNULL_END
