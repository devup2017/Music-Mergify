//
//  SearchMusicVC.h
//  Mergify
//
//  Created by Abhishek Kumar on 07/12/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchMusicVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *view_LocalBG;
@property (nonatomic, weak) IBOutlet UIButton *btn_Local;

@property (nonatomic, weak) IBOutlet UIView *view_SpotifyBG;
@property (nonatomic, weak) IBOutlet UIButton *btn_Spotify;

@property (nonatomic, weak) IBOutlet UIView *view_SoundcloudBG;
@property (nonatomic, weak) IBOutlet UIButton *btn_Soundcloud;

@property (nonatomic, weak) IBOutlet UIView *view_DeezerBG;
@property (nonatomic, weak) IBOutlet UIButton *btn_Deezer;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *tableFooterView;

- (IBAction)btn_Action:(id)sender;

@property (nonatomic, strong) NSString *searchedString;

@property (nonatomic, strong) NSMutableArray *arr_data;


@end
