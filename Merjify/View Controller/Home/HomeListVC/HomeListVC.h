//
//  HomeListVC.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundCloud.h"


@protocol songListDelegate <NSObject>

@optional
- (void)soundcloudSongListFetched;

@end

@interface HomeListVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) id <songListDelegate> delegate;


@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, retain) SoundCloud *soundCloud;

//- (void)testMethod;

@end
