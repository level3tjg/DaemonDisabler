#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSwitchTableCell.h>

@interface UIView (Private)
@property (nonatomic, assign) NSArray *allSubviews;
@end

@interface PSTableCell (Custom)
@end

@interface PSControlTableCell (Custom)
-(UIControl *)control;
@end

@interface PSSwitchTableCell (Custom)
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface SRSwitchTableCell : PSSwitchTableCell
@end

@interface ddRootListController : PSListController <UISearchBarDelegate>
@end
