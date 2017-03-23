//
//  HomeVC.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "HomeVC.h"

#import "UIImageView+WebCache.h"

#import "YSLContainerViewController.h"
#import "HomeCollectionVC.h"
#import "HomeListVC.h"
#import "PlayerViewController.h"

// Model...
#import "PlayerStatus.h"

#import "MiniToLargeViewAnimator.h"
#import "MiniToLargeViewInteractive.h"

#import "SearchMusicVC.h"

@import GoogleMobileAds;

@interface HomeVC ()<YSLContainerViewControllerDelegate,SPTAudioStreamingDelegate,SongPlayerControllerDelegate,songListDelegate,UIViewControllerTransitioningDelegate,SearchTextViewDelegate>
{
    UIButton *playBtn;
    UILabel *title;
    UILabel *subTitle;
    UIImageView *sognFileCoverImage;
    BOOL isPlaying;
    UIButton *showPlayerViewBtn;
    
    UIActivityIndicatorView *spinner;
    
    NSArray *trackArray;

    NSInteger playingSongTrackIndex;
    
    BOOL isHomeViewDisplaying;
    
    
    // popup setup
    UIView *popView;
    UITableView *searchTableView;
    NSMutableArray *searchResults;
}

@property (nonatomic, strong) GADBannerView  *bannerView;

//@property (nonatomic) MiniToLargeViewInteractive *presentInteractor;
//@property (nonatomic) MiniToLargeViewInteractive *dismissInteractor;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundColor:NAVIGATION_BAR_COLOR];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationItem.titleView = [[CommonUtils sharedInstance] getText];
    
    searchResults = [NSMutableArray array];
    
    [[CommonUtils sharedInstance] setSearchDelegate:self];
    
    [CommonUtils setStatusBarBackgroundColor:NAVIGATION_BAR_COLOR];
    
    isPlaying = NO;
    
    HomeCollectionVC *artist = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeCollectionVC"];
    HomeCollectionVC *album = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeCollectionVC"];
    HomeCollectionVC *playlist = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeCollectionVC"];
    
    HomeListVC *song = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeListVC"];
    song.delegate = self;
    
    
    artist.title = @"Artist";
    album.title = @"Album";
    song.title = @"Songs";
    playlist.title = @"Playlist";
    
    // ContainerView
    float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float navigationHeight = self.navigationController.navigationBar.frame.size.height;
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[song,artist,album,playlist] topBarHeight:statusHeight + navigationHeight parentViewController:self];
    
    containerVC.delegate = self;
    containerVC.menuItemFont = [UIFont fontWithName:FONT_NAME size:SCREEN_WIDTH==320?12:(SCREEN_WIDTH==375?13:14)];
    
    [self.view addSubview:containerVC.view];
    
    [self bottomPlayViewBarSetup];
    
    playingSongTrackIndex = 0;
    
    // Control Center...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleControlCenterAction:) name:@"ControlCenterAction" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTracks:) name:@"updateSoundcloudTracks" object:nil];
    //.................
    
    self.bannerView.adUnitID = AdMobID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    //GADRequest *request = [GADRequest request];
    //request.testDevices = @[@"8534e84ac109f246c3f9419e7131f2cae9888f6c"];

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
    
    
    showPlayerViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH - 40, 44)];
    [showPlayerViewBtn setBackgroundColor:[UIColor clearColor]];
    [showPlayerViewBtn addTarget:self action:@selector(showPlayerViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [viewBG addSubview:showPlayerViewBtn];
    
    [self.view addSubview:viewBG];
}

- (void)viewWillAppear:(BOOL)animated {
    
    isHomeViewDisplaying = YES;
    
    [[SongPlayerController sharedInstance] setDelegate:self];
    
    playingSongTrackIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
    
    [self performSelector:@selector(updateBottomWithDelay) withObject:nil afterDelay:1];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    isHomeViewDisplaying = NO;
}

- (void)updateBottomWithDelay {
    
    trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
    NSLog(@"trackArrya%@",trackArray);
    if (trackArray == nil) {
        [title setText:[NSString stringWithFormat:@""]];
        [subTitle setText:[NSString stringWithFormat:@""]];
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
        [playBtn setSelected:NO];
        
    } else {
        
        [self updateBottomBarWithIndex:playingSongTrackIndex];
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"playerStartPlayingNewTrack" object:[NSString stringWithFormat:@"%ld",(long)playingSongTrackIndex]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button Action

- (void)playButtonTapped:(UIButton *)sender {
   
    if (trackArray == nil || [trackArray count] == 0) {
        return;
    }
    
    if ([[[trackArray objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        if (!isPlaying) {
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            isPlaying = YES;
            
        } else {
            
            if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying] || [[SongPlayerController sharedInstance] spotify_player].playbackState > 0) {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                isPlaying = NO;
                
            } else {
                
                trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                
                if ([SongPlayerController sharedInstance].isPlayingAlbum || [SongPlayerController sharedInstance].isPlayingPlaylist) {
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                }else {
                    
                    [[SongPlayerController sharedInstance] setArr_songList:trackArray];
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                }                
               isPlaying = NO;
            }
        }
        
    } else if ([[[trackArray objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        if (!isPlaying) {
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            isPlaying = YES;
            
        } else {
            
            if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying || [[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0) {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                isPlaying = NO;
                
            } else {
                
                trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                
                [[SongPlayerController sharedInstance] setArr_songList:trackArray];
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                isPlaying = NO;
            }
        }
        
    } else if ([[[trackArray objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        if (!isPlaying) {
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
             isPlaying = YES;
            
        } else {
            
            float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate];
            
            //float time = CMTimeGetSeconds(currentTime);
            
            if (time > 0) {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                [playBtn setSelected:YES];
                isPlaying = NO;
            } else {
                
                trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                
                [[SongPlayerController sharedInstance] setArr_songList:trackArray];
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                [playBtn setSelected:YES] ;
                isPlaying = NO;
            }
        }
    } else if ([[[trackArray objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        if (!isPlaying && [[SongPlayerController sharedInstance] deezerProgress] > 0) {
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            isPlaying = YES;
            
        } else {
            
            if ([[[SongPlayerController sharedInstance] deezer_player] isPlaying] || [[SongPlayerController sharedInstance] deezerProgress] > 0) {
                
                [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                isPlaying = NO;
                
            } else {
                
                trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                
                if ([SongPlayerController sharedInstance].isPlayingAlbum || [SongPlayerController sharedInstance].isPlayingPlaylist) {
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                }else {
                    
                    [[SongPlayerController sharedInstance] setArr_songList:trackArray];
                    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
                }
                isPlaying = NO;
            }
        }
        
    } else {
        
        ////////
    }
    
}
/*
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    MiniToLargeViewAnimator *animator = [[MiniToLargeViewAnimator alloc] init];
    animator.initialY = showPlayerViewBtn.frame.size.height;
    animator.transitionType = ModalAnimatedTransitioningTypeDismiss;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    MiniToLargeViewAnimator *animator = [[MiniToLargeViewAnimator alloc] init];
    animator.initialY = showPlayerViewBtn.frame.size.height;
    animator.transitionType = ModalAnimatedTransitioningTypePresent;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.disableInteractivePlayerTransitioning) {
        return nil;
    }
    return self.presentInteractor;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.disableInteractivePlayerTransitioning) {
        return nil;
    }
    return self.dismissInteractor;
}
*/

- (void)showPlayerViewButtonTapped:(UIButton *)sender {
    
    if (trackArray && [trackArray count]>0) {
        
        PlayerViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
        
        /*
        viewController.rootViewController = self;
        viewController.transitioningDelegate = self;
        viewController.modalTransitionStyle = UIModalPresentationCustom;
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        self.presentInteractor = [[MiniToLargeViewInteractive alloc] init];
        [self.presentInteractor attachToViewController:self withView:showPlayerViewBtn presentViewController:viewController];
        self.dismissInteractor = [[MiniToLargeViewInteractive alloc] init];
        [self.dismissInteractor attachToViewController:viewController withView:viewController.view presentViewController:nil];
        
        self.disableInteractivePlayerTransitioning = YES;
//        [self presentViewController:viewController animated:YES completion:^{
//            self.disableInteractivePlayerTransitioning = NO;
//        }];
        */
         
        if ([SongPlayerController sharedInstance].isPlayingAlbum || [SongPlayerController sharedInstance].isPlayingPlaylist) {
            
            
        } else {
            
            trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
            [[SongPlayerController sharedInstance] setArr_songList:trackArray];
            
            /*
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                trackArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                [[SongPlayerController sharedInstance] setArr_songList:trackArray];
                
            } else {
                
                
             
            }
            */
        }
        
        [self presentViewController:viewController animated:YES completion:nil];
    }    
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[spinner stopAnimating];
            [playBtn setSelected:pStatus];
        });
    } else if ([[data valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[spinner stopAnimating];
            [playBtn setSelected:pStatus];
        });
        
    } else if ([[data valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[spinner stopAnimating];
            [playBtn setSelected:pStatus];
        });
        
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[spinner stopAnimating];
            [playBtn setSelected:pStatus];
        });
        
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
}

- (void)playerStartPlayingTrackWithData:(NSDictionary *)data {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        
        [playBtn setSelected:YES];
    });
    
    // update song list if new track started to play...
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playerStartPlayingNewTrack" object:[NSString stringWithFormat:@"%ld",(long)[SongPlayerController sharedInstance].currentPlayingTrackIndex]];
}

- (void)playerStoppedWithError {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        
        [playBtn setSelected:NO];
    });
}

- (void)playListFinished {
    
    [self performSelector:@selector(updateBottomWithDelay) withObject:nil afterDelay:0.3];
}

#pragma mark -
#pragma mark - songListDelegate

- (void)soundcloudSongListFetched {
    
    [self performSelector:@selector(updateBottomWithDelay) withObject:nil afterDelay:0.3];
}

#pragma mark -
#pragma mark - SearchTextViewDelegate

#pragma mark ---------------------------------------------
#pragma mark - Search Setup

- (void)getTextFromSearchTextField:(NSString *)txt {
    
    if (!popView) {
        [self didShowSearchTable];
    } else {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:popView];
    }
    
    [searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", txt];
    
    [searchResults addObject:txt];
    
    [searchResults addObjectsFromArray:[[trackArray filteredArrayUsingPredicate:resultPredicate] mutableCopy]];
    
    [searchTableView reloadData];
}

- (void)startSearch {
    
}

- (void)endSearch {
    
    [searchResults removeAllObjects];
    [searchTableView reloadData];
    [popView removeFromSuperview];
}

- (void)searchButtonTapped {
    
    if ([searchResults count] == 0) {
        return;
    }
    
    [self performSelector:@selector(showSideMenuWithDelay:) withObject:[searchResults objectAtIndex:0] afterDelay:0.3];
    
    [self endSearch];
    
}

#pragma mark - search table setup

- (void)didShowSearchTable {
    
    if (!popView) {
        
        popView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 55.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [popView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imageViewBG=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [imageViewBG setBackgroundColor:[UIColor blackColor]];
        [imageViewBG setAlpha:0.5];
        [popView addSubview:imageViewBG];
        
        searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(49, 0, SCREEN_WIDTH-(50*2), 200)];
        [searchTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBGBlack"]]];
        [searchTableView setSeparatorColor:[UIColor darkGrayColor]];
        [searchTableView setDelegate:self];
        [searchTableView setDataSource:self];
                
        [popView addSubview:searchTableView];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:popView];
        
    } else {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:popView];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBGBlack"]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self performSelector:@selector(showSideMenuWithDelay:) withObject:[searchResults objectAtIndex:indexPath.row] afterDelay:0.3];
    } else {
        [self performSelector:@selector(showSideMenuWithDelay:) withObject:[[searchResults objectAtIndex:indexPath.row] valueForKey:@"title"] afterDelay:0.3];
    }
    
    [self endSearch];
    
}

- (void)showSideMenuWithDelay:(NSString *)str {
    
    [THIS.sidePanelController showRightPanelAnimated:YES];
    [self performSelector:@selector(postNotification:) withObject:str afterDelay:0.5];
    
}

- (void)postNotification:(NSString *)str {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notiofySearchController" object:str];
}

#pragma mark -
#pragma mark - Private Methods

- (void)updateBottomBarWithIndex:(NSInteger)index {
    
    if ([[SongPlayerController sharedInstance].arr_songList count] > 0) {
        
        [title setText:[NSString stringWithFormat:@"%@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"title"]]];
        [subTitle setText:[NSString stringWithFormat:@"%@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistName"]]];
        
        if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            NSData *data = [[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"]:nil;
            
            if (data) {
                [sognFileCoverImage setImage:[CommonUtils convertDataintoImage:data]];
            } else {
                [sognFileCoverImage setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            }
            
        } else {
            
            [sognFileCoverImage sd_setImageWithURL:[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistImage"] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            
        }
        
        [THIS setCurrentDataBottomBar:[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex]];
        
    } else if (trackArray.count > 0) {
        
        [title setText:[NSString stringWithFormat:@"%@",[[trackArray objectAtIndex:playingSongTrackIndex] valueForKey:@"title"]]];
        [subTitle setText:[NSString stringWithFormat:@"%@",[[trackArray objectAtIndex:playingSongTrackIndex] valueForKey:@"artistName"]]];
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[trackArray objectAtIndex:playingSongTrackIndex] valueForKey:@"artistImage"]]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
        [THIS setCurrentDataBottomBar:[trackArray objectAtIndex:playingSongTrackIndex]];
        
    } else {
        
        [title setText:@""];
        [subTitle setText:@""];
        [sognFileCoverImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    
    if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying] || [[SongPlayerController sharedInstance] soundcloud_player].isPlaying || [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0 || [[[SongPlayerController sharedInstance] deezer_player] isPlaying]) {
        
        [playBtn setSelected:YES];
    } else {
        [playBtn setSelected:NO];
    }
    
}


#pragma mark -
#pragma mark - Control center Notification

// Control center action method...

- (void)handleControlCenterAction:(NSNotification *)obj {
    
    if (isHomeViewDisplaying) {
        
        playingSongTrackIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
        
        NSString *tempStr = obj.object;
        
        if ([tempStr isEqualToString:@"Play"]) {
            
            [playBtn setSelected:YES];
            [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
        } else if ([tempStr isEqualToString:@"Pause"]) {
            
            [playBtn setSelected:NO];
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
        } else if ([tempStr isEqualToString:@"Previous"]) {
            
            NSLog(@"playingSongTrackIndex ------------ %ld",(long)playingSongTrackIndex);
            
            if (playingSongTrackIndex == 0) {
                return;
            }
            
#warning suffle setup
            
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                playingSongTrackIndex--;
                
            } else {
                
                playingSongTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[trackArray count]-1 andCurrentIndex:playingSongTrackIndex];
            }
            
            
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:playingSongTrackIndex];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"playerStartPlayingNewTrack" object:[NSString stringWithFormat:@"%ld",(long)[SongPlayerController sharedInstance].currentPlayingTrackIndex]];
            
        } else if ([tempStr isEqualToString:@"Next"]) {
            
            
            if (playingSongTrackIndex == [trackArray count]-1) {
                return;
            }
            
#warning suffle setup
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                playingSongTrackIndex++;
                
            } else {
                
                playingSongTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[trackArray count]-1 andCurrentIndex:playingSongTrackIndex];
            }
            
             
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:playingSongTrackIndex];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"playerStartPlayingNewTrack" object:[NSString stringWithFormat:@"%ld",(long)(long)[SongPlayerController sharedInstance].currentPlayingTrackIndex]];
            
        } else {
            
            NSLog(@"****************** Control center unknown state ******************");
        }
    }
}

#pragma mark -
#pragma mark - YSLContainerViewControllerDelegate

- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    //    NSLog(@"current Index : %ld",(long)index);
    //    NSLog(@"current controller : %@",controller);
    
    [controller viewWillAppear:YES];
    
}

@end
