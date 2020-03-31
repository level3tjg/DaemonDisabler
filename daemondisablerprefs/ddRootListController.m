#include "ddRootListController.h"
#import "../NSTask.h"

@implementation SRSwitchTableCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
    }
    return self;
}

@end

@implementation ddRootListController

-(NSArray *)specifiers{
    if(!_specifiers){
        _specifiers = [NSMutableArray new];
        NSFileManager *fm = NSFileManager.defaultManager;
        NSArray *paths = @[@"/Library/LaunchDaemons", @"/System/Library/LaunchDaemons", @"/System/Library/NanoLaunchDaemons"];
        for(NSString *path in paths){
            NSArray *fileList = [fm contentsOfDirectoryAtPath:path error:nil];
            if (fileList) for(NSString *daemon in fileList) if ([daemon hasSuffix:@".plist"]){
                PSSpecifier *daemonSpecifier = [PSSpecifier preferenceSpecifierNamed:daemon target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
                [daemonSpecifier setProperty:[NSString stringWithFormat:@"%@/%@", path, daemon] forKey:@"key"];
                [daemonSpecifier setProperty:[SRSwitchTableCell class] forKey:@"cellClass"];
                [_specifiers addObject:daemonSpecifier];
            }
        }
    }
    return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier *)specifier{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist"];
    if (!prefs[specifier.properties[@"key"]]){
        return @YES;
    }
    return prefs[specifier.properties[@"key"]];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist"]];
    NSString *daemon = specifier.properties[@"key"];
    NSDictionary *daemonPlist = [NSDictionary dictionaryWithContentsOfFile:daemon];
    NSString *service = [daemonPlist objectForKey:@"Label"];
    if(!service){
        NSArray *components =  [[daemon lastPathComponent] componentsSeparatedByString:@"."];
        service = components[[components count]-2];
    }
    if([value isEqual:@NO]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DaemonDisabler" message:[NSString stringWithFormat:@"Are you sure you want to disable %@?", daemon] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){

            NSTask *task = [NSTask new];
            [task setLaunchPath:@"/usr/libexec/launchctl_wrapper"];
            [task setArguments:@[@"unload", daemon]];
            [task launch];
            [defaults setObject:value forKey:specifier.properties[@"key"]];
            [defaults writeToFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist" atomically:YES];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [(UISwitch *)specifier.properties[@"control"] setOn:TRUE animated:TRUE];
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okAction];
        [alert addAction:otherAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        NSTask *task = [NSTask new];
        [task setLaunchPath:@"/usr/libexec/launchctl_wrapper"];
        [task setArguments:@[@"load", daemon]];
        [task launch];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DaemonDisabler" message:[NSString stringWithFormat:@"Would you like to kickstart %@?", service] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            NSTask *task = [NSTask new];
            [task setLaunchPath:@"/usr/libexec/launchctl_wrapper"];
            [task setArguments:@[@"kickstart", @"-k", [NSString stringWithFormat:@"system/%@", service]]];
            [task launch];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okAction];
        [alert addAction:otherAction];
        [self presentViewController:alert animated:YES completion:nil];
        [defaults setObject:value forKey:specifier.properties[@"key"]];
        [defaults writeToFile:@"/var/mobile/Library/Preferences/com.level3tjg.daemondisabler.plist" atomically:YES];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search";
    UITableView *tableView = [self valueForKey:@"_table"];
    tableView.tableHeaderView = searchBar;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIViewController *vc = [self.navigationController valueForKey:@"_rootListController"];
    UINavigationBar *bar = [[vc navigationController] navigationBar];
    for(UILabel *label in bar.allSubviews)
        if([label isKindOfClass:[UILabel class]])
            if([label.text isEqualToString:@"DaemonDisabler"])
                label.hidden = true;
    [bar setTintColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/DaemonDisablerPrefs.bundle/Icon@3x.png"]];
    CGSize imageSize = CGSizeMake(40, 40);
    CGFloat marginX = (self.navigationController.navigationBar.frame.size.width / 2) - (imageSize.width / 2);
    imageView.frame = CGRectMake(marginX, 0, imageSize.width, imageSize.height);
    imageView.alpha = 0;
    [bar addSubview:imageView];
    [UIView animateWithDuration:1.0 animations:^(void){
        imageView.alpha = 1;
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIViewController *vc = [self.navigationController valueForKey:@"_rootListController"];
    UINavigationBar *bar = [[vc navigationController] navigationBar];
    [bar setTintColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0]];
    for(UIImageView *imageView in bar.subviews)
        if([imageView isKindOfClass:[UIImageView class]] && ![imageView isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")])
            [imageView removeFromSuperview];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self reloadSpecifiers];
    UITableView *tableView = [self valueForKey:@"_table"];
    if([searchText isEqualToString:@""] || searchText == nil){
        [tableView reloadData];
        return;
    }
    else{
        [self updateSpecifiersForSearch:searchText];
        [tableView reloadData];
        return;
    }
}

-(void)updateSpecifiersForSearch:(NSString *)searchText{
    NSMutableArray *filteredSpecifiers = [[NSMutableArray alloc] init];
    for(PSSpecifier *specifier in self.specifiers){
        NSRange r = [specifier.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(r.location != NSNotFound || [self.specifiers indexOfObject:specifier] == 0){
            [filteredSpecifiers addObject:specifier];
        }
    }
    [self setSpecifiers:[filteredSpecifiers copy]];
    return;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self updateSpecifiersForSearch:searchBar.text];
    [(UITableView *)[self valueForKey:@"_table"] reloadData];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
