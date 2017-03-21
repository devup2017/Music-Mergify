//
//  SongsListVC.h
//  Mergify
//
//  Created by Abhishek Kumar on 20/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongsListVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIImageView *img_CoverPic;

@property (nonatomic, weak) IBOutlet UIButton *navBarBG;

@property (nonatomic, strong) NSArray *arr_Tracks;

@property (nonatomic, strong) NSString *str_PlaylistTitle;

- (IBAction)btn_Close:(id)sender;

@end
