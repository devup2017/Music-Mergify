//
//  AccountsVC.h
//  Merjify
//
//  Created by Abhishek Kumar on 18/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundCloud.h"
#import "SpotifyController.h"

@interface AccountsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, retain) SoundCloud *soundCloud;

@property (nonatomic, retain) SpotifyController *spotifyController;

@end
