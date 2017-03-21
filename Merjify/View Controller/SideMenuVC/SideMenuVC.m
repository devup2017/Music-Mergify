//
//  SideMenuVC.m
//  Wechat
//
//  Created by Abhishek Kumar on 30/06/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SideMenuVC.h"

#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"

#import "iRate.h"

#import "HomeVC.h"
#import "AccountsVC.h"
#import "ProfileVC.h"
#import "UpdatePasswordVC.h"

@interface SideMenuVC ()

@end

@implementation SideMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = NAVIGATION_BAR_COLOR;
    
    _tableData = @[@"Home",@"Accounts",@"Update Password",@"Rate US",@"Share",@"Logout"];
    
    self.viewArrControllers = [NSMutableArray array];
    
    UIViewController *viewController=nil;
    
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    [self.viewArrControllers addObject:viewController];
    
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountsVC"];
    [self.viewArrControllers addObject:viewController];
    
//    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
//    [self.viewArrControllers addObject:viewController];
    
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UpdatePasswordVC"];
    [self.viewArrControllers addObject:viewController];
    
    [self.tableView setTableHeaderView:[self tableHeaderView]];
    [self.tableView setTableFooterView:[self tableFooterView]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Header & Footer

- (UIView *)tableHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-65, 50, 54, 64)];
    //[logoView setImage:[UIImage imageNamed:@"home_tallgericon.png"]];
    [view addSubview:logoView];
    
    return view;
}

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    return view;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return [_tableData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:14]];
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    cell.textLabel.text=[_tableData objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self showViewWithName:@"HomeVC" Index:0];
            break;
        case 1:
            [self showViewWithName:@"AccountsVC" Index:1];
            break;
        case 2:
            [self showViewWithName:@"UpdatePasswordVC" Index:2];
            break;
        case 3:
        {
            
            [iRate sharedInstance].applicationBundleID = @"com.neforce.talgger";
            [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
            
            //enable preview mode
            [iRate sharedInstance].previewMode = YES ;
            [[iRate sharedInstance] promptForRating];
        }
            break;
        case 4:
            
            // call method to share...
            [self shareSetup];
            
            break;
        case 5:{
            
            // Logout
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [THIS updateApplicationState];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Custom method to push view controller...

// push view controller
- (void)showViewWithName:(NSString *)string Index:(int)index{
    
    UINavigationController *navigationController = (id)[self.sidePanelController centerPanel];
    if ([[[navigationController viewControllers] objectAtIndex:0] isKindOfClass:NSClassFromString(string)]) {
        [self.sidePanelController showCenterPanelAnimated:YES];
        return;
    }
    UIViewController *viewController=[self.viewArrControllers objectAtIndex:index];
    [navigationController setViewControllers:@[viewController] animated:NO];
    [self.sidePanelController relaodView];
}



- (void)shareSetup {
    
    NSString *textToShare = APPLICATION_NAME;
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.google.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

@end
