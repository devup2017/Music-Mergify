//
//  HomeListVC.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "HomeListVC.h"

#import "UIViewController+MJPopupViewController.h"
#import "UIImageView+WebCache.h"

#import "SoundListCell.h"
#import "AddToPlaylistVCViewController.h"


@interface HomeListVC ()<WebDataManagerDelegate,PlayListDelegate>
{
    
    NSInteger selectedIndex;
    
    NSInteger more_SelectedIndex;
    
    NSMutableArray *arr_Tracks;
    
}

@end

@implementation HomeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStartPlayingNewTrack:) name:@"playerStartPlayingNewTrack" object:nil];
    
    selectedIndex = 0;
        
    [self.tableView setTableFooterView:[UIView new]];
    
    // Sound cloud setup...
    self.soundCloud =[[SoundCloud alloc] init];
    
    arr_Tracks = [NSMutableArray array];
    
    more_SelectedIndex = -1;
    
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    [super viewWillAppear:animated];
//
//}
//
- (void)viewDidAppear:(BOOL)animated {

    
    [arr_Tracks removeAllObjects];
    
    if (([[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] count] > 0)) {
        
        [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"]];
        [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([self.delegate respondsToSelector:@selector(soundcloudSongListFetched)]) {
            [self.delegate soundcloudSongListFetched];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
        
        [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySongList"]];
        
        //arr_Tracks = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySongList"];
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
        
        [arr_Tracks removeAllObjects];
        [arr_Tracks addObjectsFromArray:sortedArray];
        
        [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //[self.tableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(soundcloudSongListFetched)]) {
            [self.delegate soundcloudSongListFetched];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
        
        if ([self.title isEqualToString:@"Songs"] && [self.soundCloud login] && ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] count]==0)) {
            [self performSelector:@selector(getLoggedInUserID) withObject:nil afterDelay:0.2];
        } else {
            
            //[self.soundCloud login];
            
            [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"]];
            
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
            
            [arr_Tracks removeAllObjects];
            [arr_Tracks addObjectsFromArray:sortedArray];
            
            [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([self.delegate respondsToSelector:@selector(soundcloudSongListFetched)]) {
                [self.delegate soundcloudSongListFetched];
            }
            
            //[self.tableView reloadData];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
        
        [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerSongList"]];
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
        
        [arr_Tracks removeAllObjects];
        [arr_Tracks addObjectsFromArray:sortedArray];
        
        [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //[self.tableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(soundcloudSongListFetched)]) {
            [self.delegate soundcloudSongListFetched];
        }
    }
    
    [self.tableView reloadData];
    
    if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
        
        selectedIndex = -1;
        
    } else {
        
        selectedIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification
#pragma mark - Selected Song Notification

- (void)playerStartPlayingNewTrack:(NSNotification *)obj {
    
    if ([SongPlayerController sharedInstance].isPlayingAlbum || [SongPlayerController sharedInstance].isPlayingPlaylist) {
        
        selectedIndex = -1;
        
    } else {
        
        selectedIndex = [obj.object integerValue];
        
        //NSInteger playingSongIndex = [arr_Tracks indexOfObject:[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex]];
        
        //selectedIndex = playingSongIndex;
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    if ([self.title isEqualToString:@"Songs"]) {
        
        return arr_Tracks.count;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    SoundListCell *cell = (SoundListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SoundListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.selectedBackgroundView = [self selectedView];
    }
    //cell.view_more.hidden = YES;
    
    cell.btn_More.tag = indexPath.row;
    [cell.btn_More addTarget:self action:@selector(btn_Action_AddToPlayList:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.btn_AddToPlayList addTarget:self action:@selector(btn_Action_AddToPlayList:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.btn_Delete addTarget:self action:@selector(btn_Action_Delete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    /*
    if (indexPath.row == more_SelectedIndex) {
        
        cell.view_more.hidden = NO;
        
    }
    */
    
    if (selectedIndex == indexPath.row) {
        [cell.img_CellBG setImage:[UIImage imageNamed:@"cellBGRed"]];
        [cell.lbl_Title setTextColor:[UIColor whiteColor]];
        
    }else{
        [cell.img_CellBG setImage:[UIImage imageNamed:@"CellBG"]];
    }
    
    [cell.lbl_Counting setText:[NSString stringWithFormat:@"%ld.",(long)indexPath.row+1]];
    [cell.lbl_Title setText:[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"title"]];
    
    [cell.lbl_Username setText:[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistName"]];
    
    if ([[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
     
        //[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]
        //[CommonUtils convertDataintoImage:[NSData data]]
        
        NSData *data = [[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]:nil;
        
        if (data) {
            [cell.img_Userprofile setImage:[CommonUtils convertDataintoImage:data]];
        } else {
            [cell.img_Userprofile setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
    } else {
        
        [cell.img_Userprofile sd_setImageWithURL:[NSURL URLWithString:[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    

    CGSize textSize = [[cell.lbl_Username text] sizeWithAttributes:@{NSFontAttributeName:[cell.lbl_Username font]}];
    CGFloat strikeWidth = textSize.width + cell.lbl_Username.frame.origin.x;
    if (strikeWidth < 200) {
        cell.con_accountImageLead.constant = strikeWidth+10;
    }
    
    if ([[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_spotify.png"]];
        
    } else if ([[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_Itunes.png"]];
        
    } else if ([[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"Deezer_Icon"]];
        
    } else {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_soundcloud.png"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SoundListCell *cell = (SoundListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.lbl_Title setTextColor:[UIColor whiteColor]];
    
    selectedIndex = indexPath.row;
    
    if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying) {
        
        [[SongPlayerController sharedInstance] soundcloud_pause];
    }
    
    [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
    [[SongPlayerController sharedInstance] setIsPlayingPlaylist:NO];
    [[SongPlayerController sharedInstance] setArr_songList:arr_Tracks];
    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
    
    if ([[[arr_Tracks objectAtIndex:selectedIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"iTunesTrackChangedBeforEnd" object:nil];
    }
    
    [self.tableView reloadData];
    
    /*
    [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        if ([[SongPlayerController sharedInstance] arr_songList] == 0) {
            
            [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
            [[SongPlayerController sharedInstance] setArr_songList:arr_Tracks];
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
            
        } else {
            
            [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
        }
     
    } else {
        
        NSInteger playingSongIndex = [arr_Tracks indexOfObject:[[SongPlayerController sharedInstance].arr_songList objectAtIndex:indexPath.row]];
        
        selectedIndex = playingSongIndex;
        
        [[SongPlayerController sharedInstance] setCurrentPlayingTrackIndex:selectedIndex];
        [[SongPlayerController sharedInstance] startPlayAudioWithIndex:selectedIndex];
        
    }
    */
    /*
    if ([[SongPlayerController sharedInstance] arr_songList] == 0) {
        
        [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
        [[SongPlayerController sharedInstance] setArr_songList:arr_Tracks];
        [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
        
    } else {
        
        [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
        [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
    }
    */
    
}

#pragma mark - IBAction

-(void)btn_Action_AddToPlayList:(UIButton*)sender
{
    more_SelectedIndex = [sender tag];
    
    AddToPlaylistVCViewController *addToPlaylistVC = [[AddToPlaylistVCViewController alloc] initWithNibName:@"AddToPlaylistVCViewController" bundle:nil];
    
    addToPlaylistVC.view.layer.cornerRadius = 5.0f;
    //publishPopUpVC.view.layer.borderWidth = 0.5f;
    //publishPopUpVC.view.layer.borderColor = [UIColor colorWithRed:247.0/255.0f green:118.0/255.0f blue:219.0/255.0f alpha:1.0f].CGColor;
    
    if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] allKeys] count] > 0) {
        
        addToPlaylistVC.playListData = [[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"];
    }
    
    addToPlaylistVC.delegate=self;
    
    [self presentPopupViewController:addToPlaylistVC animationType:MJPopupViewAnimationFade];
    
    
    /*
    if (more_SelectedIndex == sender.tag) {
        
        more_SelectedIndex = -1;
        [self.tableView reloadData];
        return;
    }
    
    more_SelectedIndex = sender.tag;
    [self.tableView reloadData];
    */
    
}


#pragma mark - PlayListDelegate

- (void)cancelButtonTapped {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void)createNewPlaylistButtonTapped {
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APPLICATION_NAME message:@"New Playlist" preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tag = 101;
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelButton];
    
    UIAlertAction *createPlaylistButton = [UIAlertAction actionWithTitle:@"Create Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *titleStr = [[alert.textFields objectAtIndex:0] text];
        titleStr = [titleStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (titleStr != nil && ![titleStr isEqualToString:@""]) {
            
            [self createNewPlaylistWithTitle:titleStr andTrackDetail:[arr_Tracks objectAtIndex:more_SelectedIndex]];
        } else {
            
            Displayalert(APPLICATION_NAME,@"Please enter title to create a playlist." , self,[NSArray arrayWithObject:@"OK"],1)
            
        }
    }];
    [alert addAction:createPlaylistButton];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)selectedPlaylistTitle:(NSString *)title {
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
    [mainDic setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]];
    
    NSMutableArray *arr = [NSMutableArray array];
    [arr setArray:[mainDic valueForKey:title]];
    
    if (![arr containsObject:[arr_Tracks objectAtIndex:more_SelectedIndex]]) {
        
        [arr addObject:[arr_Tracks objectAtIndex:more_SelectedIndex]];
        [mainDic setValue:arr forKey:title];
        
        [[NSUserDefaults standardUserDefaults] setObject:mainDic forKey:@"Playlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"-------------------- %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]);
        
        if ([[SongPlayerController sharedInstance] isPlayingPlaylist]) {
            
            [[SongPlayerController sharedInstance] setArr_songList:[mainDic valueForKey:[[SongPlayerController sharedInstance] playlistTitle]]];
        }
        
        
    } else {
        
        Displayalert(APPLICATION_NAME,@"This song is already in this playlist." , self,[NSArray arrayWithObject:@"OK"],1)
        
    }
}

#pragma mark - Add to Playlist

- (void)createNewPlaylistWithTitle:(NSString *)playlistTitle andTrackDetail:(NSDictionary *)trackDetail {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] == nil || [[[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] allKeys] count] == 0) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:trackDetail];
        [dic setObject:arr forKey:playlistTitle];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"Playlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] allKeys] count] > 0) {
        
        if (![[[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] allKeys] containsObject:playlistTitle]) {
            
            NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
            [mainDic setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]];
            
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:trackDetail];
            
            [mainDic setObject:arr forKey:playlistTitle];
            
            [[NSUserDefaults standardUserDefaults] setObject:mainDic forKey:@"Playlist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            
            Displayalert(APPLICATION_NAME,@"Playlist exist with same name, Please try another name." , self,[NSArray arrayWithObject:@"OK"],1)
            
        }
        
    } else {
        
        // Nothing to do...
    }
    
    
    NSLog(@"-------------------- %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]);
    
}


/*
- (void)btn_Action_Delete:(id)sender
{
    [WebDataManager sharedInstance].delegate = self;
    
    [[WebDataManager sharedInstance] showAlert:APPLICATION_NAME withMessage:@"Do you really want to delete?" withViewController:self withButtonsArr:[NSArray arrayWithObjects:@"Cancel",@"Delete", nil] withAlertViewTag:101];
}
*/
/*
#pragma mark - WebDataManagerDelegate

- (void)alertViewButtonClicked:(NSInteger)buttonIndex withAlertViewTag:(NSInteger)alertViewTag {
    
    if (alertViewTag == 101) {
        
        if (buttonIndex == 1) {
            
            //NSLog(@"%@",arr_Tracks);
            //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]);
            
            
            if ([[[arr_Tracks objectAtIndex:more_SelectedIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
                
                
                
            } else if ([[[arr_Tracks objectAtIndex:more_SelectedIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
                
                
                NSURLRequest *request = [SPTPlaylistSnapshot createRequestForRemovingTracks:@[[NSURL URLWithString:[[arr_Tracks objectAtIndex:more_SelectedIndex] valueForKey:@"uri"]]] fromPlaylist:[NSURL URLWithString:[[arr_Tracks objectAtIndex:more_SelectedIndex] valueForKey:@"playlistURL"]] withAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"] snapshot:[[arr_Tracks objectAtIndex:more_SelectedIndex] valueForKey:@"snapshotId"] error:nil];
                
                [[SPTRequest sharedHandler] performRequest:request callback:^(NSError *error, NSURLResponse *response, NSData *data) {
                    
                    if (error) {
                        NSLog(@"*** **** ****** ****** ******* %@", [error localizedDescription]);
                        return;
                    }
                    
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    NSLog(@"*** json *** %@", json);
                    
                }];
                
                
            } else {
                
                /////////////
            }
            
            
        }
        
        more_SelectedIndex = -1;
        [self.tableView reloadData];
    }
}
*/

#pragma mark - Webservices

- (void)getLoggedInUserID {
        
    NSString *params = [NSString stringWithFormat:@"/me?oauth_token=%@",[[NSUserDefaults standardUserDefaults] valueForKey:SC_TOKEN]];
    
    //NSLog(@"params ----- %@",params);
    
    [[WebDataManager sharedInstance] executeCallWithParamater:params withViewController:self withBlock:^(NSDictionary *items, NSError *error)
     {
         
         //NSLog(@"Soundcloud response ---- >>>>%@",items);
         
         if ([items isKindOfClass:[NSDictionary class]])
         {
             if ([items count]>0)
             {
                 
                 [self getSoundcloudTrackListWithID:[items valueForKey:@"id"]];
                 
                 
             }else{
                 
                 Displayalert(APPLICATION_NAME,@"Unable to fetch data from \"Soundcloud\"." , self,[NSArray arrayWithObject:@"OK"],1)
             }
         }
         
     }];
}

- (void)getSoundcloudTrackListWithID:(NSString *)userID {
    
    NSString *params = [NSString stringWithFormat:@"/users/%@/playlists?oauth_token=%@",userID,[[NSUserDefaults standardUserDefaults] valueForKey:SC_TOKEN]];
    
    //https://api.soundcloud.com/users/226061062/playlists?oauth_token=1-255147-226061062-bf530dca6554d
    
    //NSLog(@"params ----- %@",params);
    
    //NSLog(@"params ----- %lu",(unsigned long)[arr_Tracks count]);
    
    [[WebDataManager sharedInstance] executeCallWithParamater:params withViewController:self withBlock:^(NSDictionary *items, NSError *error)
     {
         
         //NSLog(@"Soundcloud response ---- >>>>%@",items);
         
         if ([items isKindOfClass:[NSArray class]])
         {
             if ([items count]>0)
             {
                 NSMutableArray *tempArr = [[NSMutableArray array] init];
                 
                 for (int i=0; i<[items count] ; i++) {
                     
                     for (int j=0; j<[[[items valueForKey:@"tracks"] objectAtIndex:i] count]; j++) {
                         
                         NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                         
                         [tempDic setValue:[[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"title"] objectAtIndex:j] forKey:@"title"];
                         
                         NSString *tempImageURL = [[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"artwork_url"] objectAtIndex:j];
                         [tempDic setValue:[tempImageURL isKindOfClass:[NSString class]]?tempImageURL:@"" forKey:@"artistImage"];
                         if (![[tempDic valueForKey:@"artistImage"] isEqualToString:@""]) {
                             
                             NSString *str = [tempDic valueForKey:@"artistImage"];
                             
                             str = [str stringByReplacingOccurrencesOfString:@"large.jpg" withString:@"t500x500.jpg"];
                             [tempDic setValue:str forKey:@"artistImage"];
                         }
                         
                         [tempDic setValue:@"soundcloud" forKey:@"accountType"];
                         
                         [tempDic setValue:[[[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"user"] objectAtIndex:j] valueForKey:@"username"] forKey:@"artistName"];
                         
                         [tempDic setValue:[[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"duration"] objectAtIndex:j] forKey:@"duration"];
                         
                         [tempDic setValue:[[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"id"] objectAtIndex:j] forKey:@"id"];
                         
                         [tempDic setValue:[[[[items valueForKey:@"tracks"] objectAtIndex:i] valueForKey:@"uri"] objectAtIndex:j] forKey:@"uri"];
                         
                         [tempArr addObject:tempDic];
                         
                     }
                 }
                 /*
                 NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                 NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                 NSArray *sortedArray = [tempArr sortedArrayUsingDescriptors:sortDescriptors];
                 
                 [arr_Tracks removeAllObjects];
                 [arr_Tracks addObjectsFromArray:sortedArray];
                 
                 [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
                 */
                 if (tempArr.count > 0)
                     [[NSUserDefaults standardUserDefaults] setValue:tempArr forKey:@"soundcloudTracks"];
                 
                 if (([[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] count] > 0)) {
                     
                     [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"]];
                     
                     NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                     NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                     NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
                     
                     [arr_Tracks removeAllObjects];
                     [arr_Tracks addObjectsFromArray:sortedArray];
                     
                     [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
                     
                     
                 }
                 
                 if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
                     
                     [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySongList"]];
                     
                     NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                     NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                     NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
                     
                     [arr_Tracks removeAllObjects];
                     [arr_Tracks addObjectsFromArray:sortedArray];
                     
                     [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
                     
                 }
                 
                 if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
                     
                     if ([self.title isEqualToString:@"Songs"] && [self.soundCloud login] && ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] count]==0)) {
                         [self performSelector:@selector(getLoggedInUserID) withObject:nil afterDelay:0.2];
                     } else {
                         
                         [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"]];
                         
                         NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                         NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                         NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
                         
                         [arr_Tracks removeAllObjects];
                         [arr_Tracks addObjectsFromArray:sortedArray];
                         
                         [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
                     }
                 }
                 
                 if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
                     
                     [arr_Tracks addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerSongList"]];
                     
                     NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                     NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                     NSArray *sortedArray = [arr_Tracks sortedArrayUsingDescriptors:sortDescriptors];
                     
                     [arr_Tracks removeAllObjects];
                     [arr_Tracks addObjectsFromArray:sortedArray];
                     
                     [[NSUserDefaults standardUserDefaults] setValue:arr_Tracks forKey:@"tracks"];
                     
                 }
                 
                 [self.tableView reloadData];
                 
                 if ([self.delegate respondsToSelector:@selector(soundcloudSongListFetched)]) {
                     [self.delegate soundcloudSongListFetched];
                 }
                 
             }else{
                 
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudTracks"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 Displayalert(APPLICATION_NAME,@"Unable to fetch data from \"Soundcloud\"." , self,[NSArray arrayWithObject:@"OK"],1)
             }
         }else{
             
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudTracks"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             Displayalert(APPLICATION_NAME,@"Unable to fetch data from \"Soundcloud\"." , self,[NSArray arrayWithObject:@"OK"],1)
         }
         
     }];
    
}

@end
