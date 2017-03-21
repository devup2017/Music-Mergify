//
//  AddToPlaylistVCViewController.h
//  Mergify
//
//  Created by Abhishek Kumar on 08/09/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayListDelegate<NSObject>

@optional
- (void)cancelButtonTapped;
- (void)createNewPlaylistButtonTapped;
- (void)selectedPlaylistTitle:(NSString *)title;

@end


@interface AddToPlaylistVCViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (assign, nonatomic) id <PlayListDelegate>delegate;

- (IBAction)btn_Action_Cancel:(id)sender;
- (IBAction)btn_Action_NewPlaylist:(id)sender;


@property (nonatomic, strong) NSDictionary *playListData;


@end
