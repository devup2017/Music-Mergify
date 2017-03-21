//
//  SongsListVC.m
//  Mergify
//
//  Created by Abhishek Kumar on 20/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SongsListVC.h"

#import "UIImageView+WebCache.h"

#import "UIViewController+MJPopupViewController.h"

#import "SoundListCell.h"

#import "PlayerViewController.h"
#import "AddToPlaylistVCViewController.h"

// Model...
#import "PlayerStatus.h"

@import GoogleMobileAds;



@interface SongsListVC ()<SongPlayerControllerDelegate,PlayListDelegate>
{
    UIButton *playBtn;
    UILabel *title;
    UILabel *subTitle;
    UIImageView *sognFileCoverImage;
    UIActivityIndicatorView *spinner;
    
    NSInteger selectedIndex;
    
    BOOL isSongListViewPresented;
    
    //BOOL isSuffleSelected;
    
    NSInteger more_SelectedIndex;
    
}

@property (nonatomic, strong) GADBannerView  *bannerView;

@end

@implementation SongsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleControlCenterAction:) name:@"ControlCenterAction" object:nil];
    
    selectedIndex = 0;
    
    more_SelectedIndex = -1;
    
    if ([[[self.arr_Tracks objectAtIndex:0] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        //[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]
        //[CommonUtils convertDataintoImage:[NSData data]]
        
        NSData *data = [[[self.arr_Tracks objectAtIndex:0] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[self.arr_Tracks objectAtIndex:0] valueForKey:@"artistImage"]:nil;
        
        if (data) {
            [_img_CoverPic setImage:[CommonUtils convertDataintoImage:data]];
        } else {
            [_img_CoverPic setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
    } else {
        
        [_img_CoverPic sd_setImageWithURL:[NSURL URLWithString:[[self.arr_Tracks objectAtIndex:0] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    
    
    
    [self bottomPlayViewBarSetup];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    self.bannerView.adUnitID = AdMobID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    isSongListViewPresented = YES;
    
    [CommonUtils setStatusBarBackgroundColor:[UIColor clearColor]];
    
    //NSLog(@"-----------%@",_arr_Tracks);
    
    //NSLog(@"-----------%@",[[[SongPlayerController sharedInstance] arr_songList] objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex]);

    
    if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
        
        if ([[[SongPlayerController sharedInstance] arr_songList] count]>0) {
            
            if ([_arr_Tracks containsObject:[[[SongPlayerController sharedInstance] arr_songList] objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex]]) {
                
                if ([[SongPlayerController sharedInstance] isPlayingAlbum] && _str_PlaylistTitle.length == 0) {
                    
                    selectedIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
                    
                } else if ([[SongPlayerController sharedInstance] isPlayingPlaylist]) {
                    
                    selectedIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
                    
                } else {
                    
                    selectedIndex = -1;
                }
                
            } else {
                
                selectedIndex = -1;
            }
            
        } else {
            
            selectedIndex = -1;
        }
        
    } else {
        
        selectedIndex = -1;
        
    }
    
    [[SongPlayerController sharedInstance] setDelegate:self];
    
    [self updateView];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    isSongListViewPresented = YES;
    
    //[CommonUtils setStatusBarBackgroundColor:NAVIGATION_BAR_COLOR];
}

- (void)bottomPlayViewBarSetup {
    
    UIView *viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-94, SCREEN_WIDTH, 94)];
    [viewBG setBackgroundColor:[UIColor lightGrayColor]];
    [viewBG.layer setShadowColor:[UIColor whiteColor].CGColor];
    [viewBG.layer setShadowOpacity:0.6];
    [viewBG.layer setShadowRadius:3.0];
    [viewBG.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    
//    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
//    [adView setBackgroundColor:[UIColor redColor]];
//    [viewBG addSubview:adView];
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(SCREEN_WIDTH, 50)) origin:CGPointMake(0, 0)];
    [viewBG addSubview:self.bannerView];
    
    UIImageView *imgViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 44)];
    [imgViewBG setImage:[UIImage imageNamed:@"cellBGBlack"]];
    [viewBG addSubview:imgViewBG];
    
    sognFileCoverImage = [[UIImageView alloc] initWithFrame:CGRectMake(4, 54, 36, 36)];
    [sognFileCoverImage setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    [viewBG addSubview:sognFileCoverImage];
    
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 36, 58, 28, 28)];
    [playBtn setImage:[UIImage imageNamed:@"PlayerPlay"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"PlayerPause"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [viewBG addSubview:playBtn];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(sognFileCoverImage.frame.origin.x + sognFileCoverImage.frame.size.width+8, 58, SCREEN_WIDTH - (sognFileCoverImage.frame.size.width + playBtn.frame.size.width) - 32, 12)];
    [title setTextColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
    [title setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [viewBG addSubview:title];
    
    subTitle = [[UILabel alloc] initWithFrame:CGRectMake(sognFileCoverImage.frame.origin.x + sognFileCoverImage.frame.size.width+8, 72, SCREEN_WIDTH - (sognFileCoverImage.frame.size.width + playBtn.frame.size.width) - 32, 14)];
    [subTitle setTextColor:[UIColor whiteColor]];
    [subTitle setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [viewBG addSubview:subTitle];
    
    
    //main thread
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setFrame:CGRectMake(SCREEN_WIDTH/2, 70, 20, 20)];
    [spinner setHidesWhenStopped:YES];
    [viewBG addSubview:spinner];
    
    
    UIButton *showPlayerViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH - 40, 44)];
    [showPlayerViewBtn setBackgroundColor:[UIColor clearColor]];
    [showPlayerViewBtn addTarget:self action:@selector(showPlayerViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [viewBG addSubview:showPlayerViewBtn];
    
    [self.view addSubview:viewBG];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return self.arr_Tracks.count;
    
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
    
    if (selectedIndex == indexPath.row) {
        [cell.img_CellBG setImage:[UIImage imageNamed:@"cellBGRed"]];
        [cell.lbl_Title setTextColor:[UIColor whiteColor]];
        
        if ([_str_PlaylistTitle length] > 0)
            [cell.img_MoreImage setImage:[UIImage imageNamed:@"DeleteWhite"]];
        
    }else{
        [cell.img_CellBG setImage:[UIImage imageNamed:@"CellBG"]];
        
        if ([_str_PlaylistTitle length] > 0)
            [cell.img_MoreImage setImage:[UIImage imageNamed:@"Delete"]];
    }    
    
    cell.btn_More.tag = indexPath.row;
    [cell.btn_More addTarget:self action:@selector(btn_Action_Delete:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.lbl_Counting setText:[NSString stringWithFormat:@"%ld.",(long)indexPath.row+1]];
    [cell.lbl_Title setText:[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"title"]];
    
    [cell.lbl_Username setText:[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistName"]];
    
    [cell.img_Userprofile sd_setImageWithURL:[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    
    CGSize textSize = [[cell.lbl_Username text] sizeWithAttributes:@{NSFontAttributeName:[cell.lbl_Username font]}];
    CGFloat strikeWidth = textSize.width + cell.lbl_Username.frame.origin.x;
    if (strikeWidth < 200) {
        cell.con_accountImageLead.constant = strikeWidth+10;
    }
    
    if ([[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_spotify.png"]];
        
    } else if ([[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_Itunes.png"]];
        
    } else if ([[[self.arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"Deezer_Icon"]];
        
    } else {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_soundcloud.png"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SoundListCell *cell = (SoundListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.lbl_Title setTextColor:[UIColor whiteColor]];
    selectedIndex = indexPath.row;
    
    if (_str_PlaylistTitle.length > 0) {
        
        [[SongPlayerController sharedInstance] setIsPlayingPlaylist:YES];
        [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
    } else {
        
        [[SongPlayerController sharedInstance] setIsPlayingAlbum:YES];
        [[SongPlayerController sharedInstance] setIsPlayingPlaylist:NO];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        [[SongPlayerController sharedInstance] setArr_songList:_arr_Tracks];
        
    } else {
        
        
        // Nothing to do...
    }
    
    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
    
    [THIS setCurrentDataBottomBar:[_arr_Tracks objectAtIndex:indexPath.row]];
    
    [self.tableView reloadData];
    
    /*
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"] count]>0) {
            
            NSArray *tempArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"];
            
            [[NSUserDefaults standardUserDefaults] setValue:tempArr forKey:@"tracks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[SongPlayerController sharedInstance] setArr_songList:tempArr];
        }
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setValue:self.arr_Tracks forKey:@"originalArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSArray *tempArr = [CommonUtils shuffleArray:self.arr_Tracks];
        
        [[NSUserDefaults standardUserDefaults] setValue:tempArr forKey:@"tracks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[SongPlayerController sharedInstance] setArr_songList:tempArr];
        
    }
    
     
    
    [[SongPlayerController sharedInstance] setIsPlayingAlbum:YES];
    [[SongPlayerController sharedInstance] setArr_songList:_arr_Tracks];
    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:indexPath.row];
    
    [THIS setCurrentDataBottomBar:[_arr_Tracks objectAtIndex:indexPath.row]];
    
    [self.tableView reloadData];
    
    */
}

#pragma mark -
#pragma mark - IBAction

- (IBAction)btn_Close:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)playButtonTapped:(UIButton *)sender {
    
    if ([playBtn isSelected]) {
        
        [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
        
    } else {
        
        float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
        
        //float time = CMTimeGetSeconds(currentTime);
        
        if ((float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] > 0) {
            
            if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                
            } else {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            }
            
        } else if ([[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0) {
            
            if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                
            } else {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            }
            
        } else if (time > 0 ) {
            
            if (([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) && time == 0) {
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                
            } else {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            }
            
        } else if ([[SongPlayerController sharedInstance] deezerProgress] > 0) {
            
            if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
                
                if ([[[SongPlayerController sharedInstance] deezer_player] isPlaying] || [[SongPlayerController sharedInstance] deezerProgress] > 0) {
                    
                    [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                } else {
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                }
                
            } else {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            }
            
        } else {
            
            [[SongPlayerController sharedInstance] setArr_songList:_arr_Tracks];
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
        }
    }
    
    
    /*
    if ([[[self.arr_Tracks objectAtIndex:selectedIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        if ([playBtn isSelected]) {
            
            [[SoundCloudPlayerController sharedInstance] pauseSong];
            
        } else {
            
            if ([[SoundCloudPlayerController sharedInstance] player].currentTime == 0) {
                
                // Call method to play song...
                [self didPlaySoundcloudSong];
                
            } else {
                
                [[SoundCloudPlayerController sharedInstance] playSong];
            }
        }
        
    } else if ([[[self.arr_Tracks objectAtIndex:selectedIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [[SpotifyPlayerController sharedInstance] playPause];
        
        if ([[SpotifyPlayerController sharedInstance] player].currentPlaybackPosition == 0) {
            
            // Call method to play song...
            [self didPlaySpotifySong];
            
        }
        
        [THIS didUpdatingControlCenterPlayStatus:[[[SpotifyPlayerController sharedInstance] player] isPlaying]?NO:YES];
        
        
    } else {
        
        
    }
    
    
    playBtn.selected = !playBtn.selected;
    */
}

- (void)showPlayerViewButtonTapped:(UIButton *)sender {
    
    PlayerViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
    
    if ([[SongPlayerController sharedInstance] isPlayingAlbum] || [[SongPlayerController sharedInstance] isPlayingPlaylist]) {
        
        
    } else {
        
        viewController.arr_Tracks = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
        [[SongPlayerController sharedInstance] setArr_songList:viewController.arr_Tracks];
        
    }
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (void)btn_Action_Delete:(UIButton *)sender
{
    if ([_str_PlaylistTitle length] > 0) {
        
        NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
        [mainDic setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]];
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr setArray:[mainDic valueForKey:_str_PlaylistTitle]];
        
        [arr removeObjectAtIndex:[sender tag]];
        
        [mainDic setValue:arr forKey:_str_PlaylistTitle];        
        
        self.arr_Tracks = [mainDic valueForKey:_str_PlaylistTitle];
        
        if (self.arr_Tracks.count > 0) {
            
            [_img_CoverPic sd_setImageWithURL:[NSURL URLWithString:[[self.arr_Tracks objectAtIndex:0] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            
        } else if (self.arr_Tracks.count == 0) {
            
            [mainDic removeObjectForKey:_str_PlaylistTitle];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:mainDic forKey:@"Playlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //NSLog(@"-------------------- %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]);
        
        
        if ([[SongPlayerController sharedInstance] isPlayingPlaylist]) {
            
            [[SongPlayerController sharedInstance] setArr_songList:self.arr_Tracks];
            
            if ([[SongPlayerController sharedInstance] currentPlayingTrackIndex] == [sender tag]) {
                
                if (self.arr_Tracks.count > 0 && selectedIndex < [[[SongPlayerController sharedInstance] arr_songList] count]) {
                    
                    selectedIndex = [sender tag];
                    [[SongPlayerController sharedInstance] setCurrentPlayingTrackIndex:selectedIndex];
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:selectedIndex];
                    
                } else if (self.arr_Tracks.count == 0) {
                    
                    [[SongPlayerController sharedInstance] setCurrentPlayingTrackIndex:0];
                    [[SongPlayerController sharedInstance] spotify_pause];
                    [[SongPlayerController sharedInstance] soundcloud_pause];
                    
                    [playBtn setSelected:NO];
                    
                } else {
                    
                    [[SongPlayerController sharedInstance] setCurrentPlayingTrackIndex:0];
                    [[SongPlayerController sharedInstance] spotify_pause];
                    [[SongPlayerController sharedInstance] soundcloud_pause];
                    
                    [self performSelector:@selector(updateView) withObject:nil afterDelay:0.3];
                }
                
            } else if ([sender tag] < [[SongPlayerController sharedInstance] currentPlayingTrackIndex]) {
                
                selectedIndex--;
                
                [[SongPlayerController sharedInstance] setCurrentPlayingTrackIndex:selectedIndex];
                
            } else {
                
                // Nothing to do...
            }
        }
        
        [self.tableView reloadData];
        
    } else {
        
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
        
    }
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
            
            [self createNewPlaylistWithTitle:titleStr andTrackDetail:[self.arr_Tracks objectAtIndex:more_SelectedIndex]];
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

- (void)selectedPlaylistTitle:(NSString *)titleStr {
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    
    NSMutableDictionary *mainDic = [NSMutableDictionary dictionary];
    [mainDic setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]];
    
    NSMutableArray *arr = [NSMutableArray array];
    [arr setArray:[mainDic valueForKey:titleStr]];
    
    if (![arr containsObject:[_arr_Tracks objectAtIndex:more_SelectedIndex]]) {
        
        [arr addObject:[_arr_Tracks objectAtIndex:more_SelectedIndex]];
        [mainDic setValue:arr forKey:titleStr];
        
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
            
            //NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:trackDetail];
            //[dic setObject:arr forKey:playlistTitle];
            
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


#pragma mark -
#pragma mark - SongPlayerControllerDelegate

- (void)updateViewForSelectedSongWithData:(NSDictionary *)data andPlayButtonStatus:(BOOL)pStatus {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        pStatus == YES?[spinner startAnimating]:[spinner stopAnimating];
    });
    
    [title setText:[NSString stringWithFormat:@"%@",[data valueForKey:@"title"]]];
    [subTitle setText:[NSString stringWithFormat:@"%@",[data valueForKey:@"artistName"]]];
    
    if ([[data valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        NSData *data1 = [[data valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[data valueForKey:@"artistImage"]:nil;
        
        if (data1) {
            [sognFileCoverImage setImage:[CommonUtils convertDataintoImage:data1]];
        } else {
            [sognFileCoverImage setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
    } else {
        
        [sognFileCoverImage sd_setImageWithURL:[data valueForKey:@"artistImage"] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    
    [playBtn setSelected:pStatus];
}

- (void)playerStartPlayingTrackWithData:(NSDictionary *)data {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        
        [playBtn setSelected:YES];
        
        selectedIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
        
        [self.tableView reloadData];
        
    });
}

- (void)playerStoppedWithError {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        
        [playBtn setSelected:NO];
    });
}

- (void)playListFinished {
    
    [self performSelector:@selector(updateView) withObject:nil afterDelay:0.3];
}

#pragma mark -
#pragma mark - Private Methods

- (void)updateView {
    
    if ([SongPlayerController sharedInstance].arr_songList.count > 0) {
        
        [title setText:[NSString stringWithFormat:@"%@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"title"]]];
        [subTitle setText:[NSString stringWithFormat:@"%@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistName"]]];
        
        if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            //[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]
            //[CommonUtils convertDataintoImage:[NSData data]]
            
            NSData *data = [[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"]:nil;
            
            if (data) {
                [sognFileCoverImage setImage:[CommonUtils convertDataintoImage:data]];
            } else {
                [sognFileCoverImage setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            }
            
        } else {
            
            [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
        //[sognFileCoverImage sd_setImageWithURL:[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    } else {
        
        [title setText:[NSString stringWithFormat:@"%@",[THIS.currentDataBottomBar valueForKey:@"title"]]];
        [subTitle setText:[NSString stringWithFormat:@"%@",[THIS.currentDataBottomBar valueForKey:@"artistName"]]];
        
        if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            //[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]
            //[CommonUtils convertDataintoImage:[NSData data]]
            
            NSData *data = [[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"]:nil;
            
            if (data) {
                [sognFileCoverImage setImage:[CommonUtils convertDataintoImage:data]];
            } else {
                [sognFileCoverImage setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            }
            
        } else {
            
            //NSLog(@"%@",[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex]);
            
            //NSLog(@"%@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"]);
            
            [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[THIS.currentDataBottomBar valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
        //[sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[THIS.currentDataBottomBar valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    
    
    if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying] || [[[SongPlayerController sharedInstance] soundcloud_player] isPlaying] || [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0 || [[[SongPlayerController sharedInstance] deezer_player] isPlaying]) {
        
        [playBtn setSelected:YES];
        
    } else {
        
        [playBtn setSelected:NO];
    }
}

// Control center action method...

- (void)handleControlCenterAction:(NSNotification *)obj {
    
    if (isSongListViewPresented) {
        
        selectedIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
        
        NSString *tempStr = obj.object;
        
        if ([tempStr isEqualToString:@"Play"]) {
            
            [playBtn setSelected:YES];
            [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
        } else if ([tempStr isEqualToString:@"Pause"]) {
            
            [playBtn setSelected:NO];
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
        } else if ([tempStr isEqualToString:@"Previous"]) {
            
            if (selectedIndex == 0) {
                return;
            }

            
#warning suffle setup
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                selectedIndex--;
                
            } else {
                
                selectedIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:selectedIndex];
            }
            
            
             
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:selectedIndex];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else if ([tempStr isEqualToString:@"Next"]) {
            
            
            if (selectedIndex == [self.arr_Tracks count]-1) {
                return;
            }
            
            
#warning suffle setup
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                selectedIndex++;
                
            } else {
                
                selectedIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:selectedIndex];
            }
            
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:selectedIndex];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            
            NSLog(@"****************** Control center unknown state ******************");
        }
    }
        
}

@end
