#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

// Method to handle number and operator input
- (IBAction)digitPressed:(UIButton *)sender;
- (IBAction)equalPressed:(UIButton *)sender;
- (IBAction)clearPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *sideView;

@property (weak, nonatomic) IBOutlet UITableView *sideBar;

- (IBAction)historyBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
- (IBAction)switch:(id)sender;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;
@property (weak, nonatomic) IBOutlet UIButton *currencyBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyBtn;
@end
