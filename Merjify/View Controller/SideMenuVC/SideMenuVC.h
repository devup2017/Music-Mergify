//
//  SideMenuVC.h
//  Wechat
//
//  Created by Abhishek Kumar on 30/06/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *viewArrControllers;

@property (nonatomic, retain) NSArray *tableData;

@end
