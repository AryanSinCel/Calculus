//
//  CountryView.h
//  Calculus
//
//  Created by Celestial on 20/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CurrencyDelegate <NSObject>

-(void)sendData:(NSMutableDictionary *) dic;

@end


@interface CountryView : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSString *selectedTextField;

@property (nonatomic,weak) id<CurrencyDelegate> delegate;

@property (nonatomic) BOOL isON;

@end

NS_ASSUME_NONNULL_END
